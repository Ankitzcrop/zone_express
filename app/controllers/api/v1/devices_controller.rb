class Api::V1::DevicesController < ApplicationController
  skip_before_action :verify_authenticity_token

  def register
    user = ::User.find_by(id: params[:user_id])

    unless user
      return render json: {
        success: false,
        message: "User not found"
      }, status: :not_found
    end

    if params[:fcm_token].blank?
      return render json: {
        success: false,
        message: "FCM token is required"
      }, status: :unprocessable_entity
    end

    unless %w[android ios].include?(params[:platform])
      return render json: {
        success: false,
        message: "Platform must be android or ios"
      }, status: :unprocessable_entity
    end

    device = Device.find_or_initialize_by(
      user_id: user.id,
      fcm_token: params[:fcm_token]
    )

    device.platform = params[:platform]

    if device.save
      render json: {
        success: true,
        message: "Device token registered successfully"
      }, status: :ok
    else
      render json: {
        success: false,
        message: device.errors.full_messages.join(", ")
      }, status: :unprocessable_entity
    end
  end
end
