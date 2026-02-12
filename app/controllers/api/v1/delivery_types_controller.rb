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
    delivery_types = DeliveryType.all

    render json: {
      success: true,
      delivery_types: delivery_types
    }
  end

  private

  def delivery_type_params
    params.permit(:name, :price, :estimated_days)
  end
end
