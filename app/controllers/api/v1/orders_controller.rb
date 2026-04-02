class Api::V1::OrdersController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :set_order, only: [
    :select_delivery_type,
    :apply_promo,
    :summary,
    :confirm
  ]

  def show
    order = Order.find_by(id: params[:id])

    if order
      render json: { success: true, order: order }
    else
      render json: { success: false, message: "Order not found" }
    end
  end

  # 1️⃣ Create Draft Order
  def create
    missing_fields = []

    missing_fields << "user_id" unless params[:user_id].present?
    missing_fields << "pickup_address_id" unless params[:pickup_address_id].present?
    missing_fields << "delivery_address_id" unless params[:delivery_address_id].present?

    if missing_fields.any?
      return render json: {
        success: false,
        message: "#{missing_fields.join(', ')} is required"
      }, status: :unprocessable_entity
    end

    pickup_address = Address.find_by(id: params[:pickup_address_id])
    delivery_address = Address.find_by(id: params[:delivery_address_id])

    unless pickup_address && delivery_address
      return render json: {
        success: false,
        message: "Pickup or delivery address not found"
      }, status: :not_found
    end

    distance = calculate_distance(pickup_address, delivery_address)
    driver_amount = calculate_driver_amount(distance)

    order = Order.new(
      user_id: params[:user_id],
      pickup_address_id: params[:pickup_address_id],
      delivery_address_id: params[:delivery_address_id],
      tracking_id: "ZX#{SecureRandom.hex(4).upcase}",
      status: :draft,
      distance: distance,
      driver_amount: driver_amount
    )

    if order.save
      render json: {
        success: true,
        message: "Order created successfully",
        order_id: order.id,
        tracking_id: order.tracking_id,
        distance: order.distance,
        driver_amount: order.driver_amount
      }
    else
      render json: {
        success: false,
        errors: order.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  def my_orders
    user_id = params[:user_id]

    # Base query (type ke hisaab se)
    case params[:type]
    when "from_me"
      orders = Order.where(user_id: user_id)
    when "to_me"
      orders = Order.where(receiver_id: user_id)
    else
      orders = Order.where(user_id: user_id)
    end

    # Category filter
    if params[:category].present?
      service = Service.find_by("LOWER(name) = ?", params[:category].downcase)
      orders = orders.where(service_id: service.id) if service
    end

    render json: {
      success: true,
      total_orders: orders.count,
      orders: orders.order(created_at: :desc)
    }
  end

  # 4️⃣ Select Delivery Type
  def select_delivery_type
    delivery_id = params[:delivery_type_id] || params.dig(:order, :delivery_type_id)

    delivery = DeliveryType.find_by(id: delivery_id)

    unless delivery
      return render json: {
        success: false,
        message: "Invalid delivery type"
      }
    end

    @order.update(delivery_type: delivery)
    calculate_total(@order)

    render json: {
      success: true,
      message: "Delivery type selected successfully",
      order: @order
    }
  end

  # 5️⃣ Apply Promo Code
  def apply_promo
    unless @order.delivery_type
      return render json: {
        success: false,
        message: "Please select delivery type first"
      }
    end

    promo = PromoCode.find_by(code: params[:code], active: true)

    unless promo
      return render json: {
        success: false,
        message: "Invalid or inactive promo code"
      }
    end

    @order.update(promo_code: promo)
    calculate_total(@order)

    render json: {
      success: true,
      message: "Promo applied successfully",
      order: @order
    }
  end

  # 6️⃣ Summary
  def summary
    render json: {
      success: true,
      tracking_id: @order.tracking_id,
      pickup_address: @order.pickup_address&.slice(
        :id, :name, :mobile, :flat, :area, :city, :state, :pincode, :label
      ),

      delivery_address: @order.delivery_address&.slice(
        :id, :name, :mobile, :flat, :area, :city, :state, :pincode, :label
      ),
      pickup_date: @order.pickup_date,
      pickup_time: @order.pickup_time,
      package_type: @order.package_type,
      package_size: @order.package_size,
      package_value: @order.package_value,
      package_contents: @order.package_contents,
      delivery_type: @order.delivery_type&.name,
      delivery_charge: @order.delivery_type&.price,
      promo_code: @order.promo_code&.code,
      discount: calculate_discount(@order),
      total_amount: @order.total_amount
    }
  end

  # 7️⃣ Confirm Order
  def confirm
    @order.update(status: "confirmed")

    render json: {
      success: true,
      message: "Order confirmed successfully",
      tracking_id: @order.tracking_id
    }
  end

  def all_orders
    orders = Order.includes(:user, :receiver, :pickup_address, :delivery_address, :service)
                  .order(created_at: :desc)

    # Optional category filter
    if params[:category].present?
      service = Service.find_by("LOWER(name) = ?", params[:category].downcase)
      orders = service.present? ? orders.where(service_id: service.id) : orders.none
    end

    render json: {
      success: true,
      total_orders: orders.count,
      orders: orders.as_json(
        only: [
          :id, :user_id, :receiver_id, :pickup_address_id, :delivery_address_id,
          :service_id, :tracking_id, :status, :total_amount, :created_at, :updated_at,
          :pickup_date, :pickup_time, :package_type, :package_size, :package_value,
          :package_contents, :delivery_type_id, :promo_code_id, :length, :breadth,
          :height, :weight, :distance, :driver_amount
        ],
        methods: [:service_category],
        include: {
          user: { only: [:id, :name, :email, :mobile] },
          receiver: { only: [:id, :name, :mobile] },
          pickup_address: {
            only: [
              :id, :name, :mobile, :flat, :area, :city, :state, :pincode, :label,
              :latitude, :longitude
            ]
          },
          delivery_address: {
            only: [
              :id, :name, :mobile, :flat, :area, :city, :state, :pincode, :label,
              :latitude, :longitude
            ]
          },
          service: { only: [:id, :name] }
        }
      )
    }, status: :ok
  end

  def accept_request
    order = Order.find_by(id: params[:id])

    unless order.present?
      return render json: {
        success: false,
        message: "Order not found"
      }, status: :not_found
    end

    if order.status == "accepted"
      return render json: {
        success: false,
        message: "This order is already accepted"
      }, status: :unprocessable_entity
    end

    update_data = { status: "accepted" }

    # optional columns only if present
    update_data[:agent_id] = params[:agent_id] if order.attributes.key?("agent_id")
    update_data[:accepted_at] = Time.current if order.attributes.key?("accepted_at")

    if order.update(update_data)
      render json: {
        success: true,
        message: "Order accepted successfully",
        data: {
          order_id: order.id,
          agent_id: params[:agent_id],
          status: order.status
        }
      }, status: :ok
    else
      render json: {
        success: false,
        message: order.errors.full_messages.join(", ")
      }, status: :unprocessable_entity
    end
  end

  private

  def set_order
    @order = Order.find_by(id: params[:id])
    render json: { success: false, message: "Order not found" } unless @order
  end

  def calculate_total(order)
    base_price = order.delivery_type&.price.to_f

    discount = calculate_discount(order)

    order.update(total_amount: base_price - discount)
  end

  def calculate_discount(order)
    return 0 unless order.promo_code

    (order.delivery_type.price * order.promo_code.discount_percentage) / 100
  end

  def calculate_distance(pickup_address, delivery_address)
    return nil unless pickup_address.latitude.present? &&
                      pickup_address.longitude.present? &&
                      delivery_address.latitude.present? &&
                      delivery_address.longitude.present?

    Geocoder::Calculations.distance_between(
      [pickup_address.latitude, pickup_address.longitude],
      [delivery_address.latitude, delivery_address.longitude],
      units: :km
    ).round(2)
  end

  def calculate_driver_amount(distance)
    return 0 unless distance.present?

    base_fare = 40
    per_km_rate = 12

    (base_fare + (distance * per_km_rate)).round(2)
  end
end
