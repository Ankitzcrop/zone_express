class Api::V1::ServicesController < ApplicationController
  skip_before_action :verify_authenticity_token

  # 1️⃣ Get All Services
  def index
    services = Service.all

    render json: {
      success: true,
      services: services
    }
  end

  # 2️⃣ Create Service
  def create
    missing = []
    missing << "name" unless params[:name].present?
    missing << "price" unless params[:price].present?

    if missing.any?
      return render json: {
        success: false,
        message: "#{missing.join(', ')} is required"
      }, status: :unprocessable_entity
    end

    service = Service.new(
      name: params[:name],
      description: params[:description],
      price: params[:price],
      active: params[:active] || true
    )

    if service.save
      render json: {
        success: true,
        message: "Service created successfully",
        service: service
      }
    else
      render json: {
        success: false,
        errors: service.errors.full_messages
      }
    end
  end

  # 3️⃣ Show Single Service
  def show
    service = Service.find_by(id: params[:id])

    if service
      render json: { success: true, service: service }
    else
      render json: { success: false, message: "Service not found" }
    end
  end

  # 4️⃣ Update Service
  def update
    service = Service.find_by(id: params[:id])
    return render json: { success: false, message: "Service not found" } unless service

    if service.update(params.permit(:name, :description, :price, :active))
      render json: { success: true, service: service }
    else
      render json: { success: false, errors: service.errors.full_messages }
    end
  end

  # 5️⃣ Delete Service
  def destroy
    service = Service.find_by(id: params[:id])
    return render json: { success: false, message: "Service not found" } unless service

    service.destroy
    render json: { success: true, message: "Service deleted successfully" }
  end
end
