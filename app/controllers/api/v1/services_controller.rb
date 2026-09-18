class Api::V1::ServicesController < ApplicationController
  skip_before_action :verify_authenticity_token

  # GET /api/v1/services
  def index
    services = Service.where(active: true).order(:id)

    render json: {
      success: true,
      data: {
        services: services.map do |service|
          {
            id: service.id,
            title: service.name,
            subtitle: service.description,
            type: service.service_type,
            icon_url: service.icon_url,
            is_active: service.active
          }
        end
      }
    }, status: :ok
  end

  # POST /api/v1/services
  def create
    missing = []
    missing << "name" unless params[:name].present?
    missing << "price" unless params[:price].present?
    missing << "service_type" unless params[:service_type].present?

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
      service_type: params[:service_type],
      icon_url: params[:icon_url],
      active: params[:active].nil? ? true : params[:active]
    )

    if service.save
      render json: {
        success: true,
        message: "Service created successfully",
        service: service
      }, status: :created
    else
      render json: {
        success: false,
        errors: service.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  # GET /api/v1/services/:id
  def show
    service = Service.find_by(id: params[:id])

    if service
      render json: {
        success: true,
        service: service
      }
    else
      render json: {
        success: false,
        message: "Service not found"
      }, status: :not_found
    end
  end

  # PATCH /api/v1/services/:id
  def update
    service = Service.find_by(id: params[:id])

    return render json: {
      success: false,
      message: "Service not found"
    }, status: :not_found unless service

    if service.update(
      params.permit(
        :name,
        :description,
        :price,
        :service_type,
        :icon_url,
        :active
      )
    )
      render json: {
        success: true,
        message: "Service updated successfully",
        service: service
      }
    else
      render json: {
        success: false,
        errors: service.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  # DELETE /api/v1/services/:id
  def destroy
    service = Service.find_by(id: params[:id])

    return render json: {
      success: false,
      message: "Service not found"
    }, status: :not_found unless service

    service.destroy

    render json: {
      success: true,
      message: "Service deleted successfully"
    }
  end
end
