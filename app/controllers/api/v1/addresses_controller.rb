class Api::V1::AddressesController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :set_user

  # Create Pickup OR Delivery
  def create
    @address = @user.addresses.new(address_params)

    full_address = [
      @address.flat,
      @address.area,
      @address.city,
      @address.state,
      @address.pincode,
      "India"
    ].compact.reject(&:blank?).join(", ")

    fallback_address = [
      @address.area,
      @address.city,
      @address.state,
      @address.pincode,
      "India"
    ].compact.reject(&:blank?).join(", ")

    Rails.logger.info "FULL ADDRESS => #{full_address}"
    Rails.logger.info "FALLBACK ADDRESS => #{fallback_address}"

    result = Geocoder.search(full_address).first

    if result.blank?
      Rails.logger.info "Full address geocoding failed, trying fallback..."
      result = Geocoder.search(fallback_address).first
    end

    Rails.logger.info "GEOCODER RESULT => #{result.inspect}"

    if result.present?
      @address.latitude = result.latitude
      @address.longitude = result.longitude
    else
      @address.latitude = nil
      @address.longitude = nil
    end

    if @address.save
      render json: {
        success: true,
        message: "#{@address.address_type.capitalize} address saved successfully",
        data: {
          id: @address.id,
          user_id: @address.user_id,
          name: @address.name,
          mobile: @address.mobile,
          flat: @address.flat,
          area: @address.area,
          pincode: @address.pincode,
          city: @address.city,
          state: @address.state,
          address_type: @address.address_type,
          label: @address.label,
          latitude: @address.latitude,
          longitude: @address.longitude
        }
      }, status: :ok
    else
      render json: {
        success: false,
        errors: @address.errors.full_messages
      }, status: :unprocessable_entity
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
    @user = User.find_by(id: params[:address][:user_id])
    render json: { success: false, message: "User not found" }, status: :not_found unless @user
  end

  def address_params
    params.require(:address).permit(
      :name,
      :mobile,
      :flat,
      :area,
      :pincode,
      :city,
      :state,
      :address_type,
      :label,
      :default
    )
  end
end
