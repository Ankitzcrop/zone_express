class Api::V1::DeliveryTypesController < ApplicationController
  skip_before_action :verify_authenticity_token

  # 🔹 Create Delivery Type
  def create
    delivery_type = DeliveryType.new(delivery_type_params)

    if delivery_type.save
      render json: {
        success: true,
        message: "Delivery type created successfully",
        delivery_type: delivery_type
      }
    else
      render json: {
        success: false,
        errors: delivery_type.errors.full_messages
      }
    end
  end

  # 🔹 List All Delivery Types

  def index
    if params[:order_id].blank?
      return render json: {
        success: false,
        message: "order_id is required"
      }, status: :bad_request
    end

    order = Order.find_by(id: params[:order_id])

    unless order
      return render json: {
        success: false,
        message: "Order not found"
      }, status: :not_found
    end

    delivery_types = DeliveryType
      .select("MIN(id) AS id, name, price, estimated_days")
      .group(:name, :price, :estimated_days)
      .sort_by do |delivery_type|
        case delivery_type.name.downcase
        when "standard"
          1
        when "express"
          2
        when "same day"
          3
        else
          4
        end
      end

    render json: {
      success: true,
      data: {
        delivery_types: delivery_types.map do |delivery_type|
          {
            id: delivery_type.id,
            name: delivery_type.name.upcase,
            title: delivery_type_title(delivery_type.name),
            price: calculate_price(order, delivery_type),
            eta_days: eta_days(delivery_type),
            description: delivery_type_description(delivery_type.name)
          }
        end
      }
    }
  end

  private

  def delivery_type_params
    params.permit(:name, :price, :estimated_days)
  end

  def calculate_price(order, delivery_type)
    base_price = order.driver_amount.to_f

    case delivery_type.name.downcase
    when "standard"
      base_price
    when "express"
      base_price * 1.5
    when "same day"
      base_price * 2
    else
      delivery_type.price.to_f
    end
  end

  def delivery_type_title(name)
    case name.downcase
    when "standard"
      "Surface Standard"
    when "express"
      "Air Express"
    when "same day"
      "Same Day Delivery"
    else
      name
    end
  end

  def eta_days(delivery_type)
    case delivery_type.name.downcase
    when "standard"
      3
    when "express"
      1
    when "same day"
      0
    else
      delivery_type.estimated_days
    end
  end

  def delivery_type_description(name)
    case name.downcase
    when "standard"
      "Economical delivery via road transit"
    when "express"
      "Priority overnight delivery"
    when "same day"
      "Fast same day delivery"
    else
      ""
    end
  end
end
