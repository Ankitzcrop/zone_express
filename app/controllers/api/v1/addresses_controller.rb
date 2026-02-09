class Api::V1::AddressesController < ApplicationController
  skip_before_action :verify_authenticity_token
  def create
    address = Address.new(address_params)
    if address.save
      render json: { success: true, address: address }
    else
      render json: { success: false, errors: address.errors }
    end
  end

  def index
    addresses = Address.where(user_id: params[:user_id])
    render json: addresses
  end

  private

  def address_params
    params.permit(
      :user_id, :name, :mobile, :flat, :area,
      :pincode, :city, :state, :address_type, :label
    )
  end
end
