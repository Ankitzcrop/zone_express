class Api::V1::AddressesController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :set_user

  # Create Pickup OR Delivery
  def create
    address = @user.addresses.new(address_params)

    if address.save
      render json: {
        success: true,
        message: "#{address.address_type.capitalize} address saved successfully",
        data: address
      }
    else
      render json: {
        success: false,
        errors: address.errors.full_messages
      }
    end
  end

  # List addresses (optionally filter by type)
  def index
    addresses = @user.addresses

    if params[:address_type].present?
      addresses = addresses.where(address_type: params[:address_type])
    end

    render json: {
      success: true,
      data: addresses
    }
  end

  private

  def set_user
    @user = User.find_by(id: params[:user_id])
    unless @user
      render json: { success: false, message: "User not found" }
    end
  end

  def address_params
    params.permit(
      :name,
      :mobile,
      :flat,
      :area,
      :pincode,
      :city,
      :state,
      :address_type,  # pickup / delivery
      :label,         # home / work / other
      :default
    )
  end
end
