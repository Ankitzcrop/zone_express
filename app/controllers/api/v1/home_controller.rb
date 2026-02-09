# app/controllers/api/v1/home_controller.rb
class Api::V1::HomeController < ApplicationController
  before_action :authorize_user

  def index
    pickup = @current_user.addresses.find_by(default: true)

    render json: {
      pickup_address: pickup ? pickup_response(pickup) : nil,
      banner: banner_data,
      help: help_data,
      track_order: track_order_data
    }, status: :ok
  end

  private

  def pickup_response(address)
    {
      id: address.id,
      address: address.address,
      pincode: address.pincode
    }
  end

  def banner_data
    {
      title: "Your World. Our Route.",
      subtitle: "18,000+ Pincodes",
      image_url: "https://cdn.app.com/banner.png"
    }
  end

  def help_data
    {
      title: "Get Help",
      action: "support"
    }
  end

  def track_order_data
    {
      title: "Track Your Orders",
      subtitle: "Get real-time status",
      button_text: "Track"
    }
  end
end
