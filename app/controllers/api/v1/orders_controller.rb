class Api::V1::OrdersController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :set_order, only: [
    :select_delivery_type,
    :apply_promo,
    :summary,
    :confirm
  ]

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

    order = Order.new(
      user_id: params[:user_id],
      pickup_address_id: params[:pickup_address_id],
      delivery_address_id: params[:delivery_address_id],
      status: :draft
    )

    if order.save
      render json: {
        success: true,
        message: "Order created successfully",
        order_id: order.id
      }
    else
      render json: {
        success: false,
        errors: order.errors.full_messages
      }
    end
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
end
