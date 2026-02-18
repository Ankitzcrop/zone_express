# app/controllers/api/v1/packages_controller.rb
class Api::V1::PackagesController < ApplicationController
  skip_before_action :verify_authenticity_token

  # 📦 Save Package Details
  def save_package
    order = Order.find_by(id: params[:order_id])

    unless order
      return render json: { success: false, message: "Order not found" }
    end

    order.update(package_params)

    render json: {
      success: true,
      message: "Package details saved successfully",
      data: order
    }
  end

  # 🔍 Filter API
  def filters
    orders = Order.all

    orders = orders.where(package_type: params[:package_type]) if params[:package_type].present?
    orders = orders.where(package_size: params[:package_size]) if params[:package_size].present?

    if params[:content].present?
      orders = orders.where("? = ANY(package_contents)", params[:content])
    end

    render json: {
      success: true,
      total: orders.count,
      data: orders
    }
  end
  
  private

  def package_params
    params.permit(
      :package_type,
      :package_size,
      :package_value,
      :length,
      :breadth,
      :height,
      :weight,
      package_contents: []
    )
  end
end
