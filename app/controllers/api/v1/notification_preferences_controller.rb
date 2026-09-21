class Api::V1::NotificationPreferencesController < ApplicationController
  skip_before_action :verify_authenticity_token

  before_action :find_user

  def show
    preferences = NotificationPreference.find_or_create_by(user_id: @user.id) do |preference|
      preference.order_updates = true
      preference.promotions = false
      preference.push_enabled = true
    end

    render json: {
      success: true,
      data: {
        order_updates: preferences.order_updates,
        promotions: preferences.promotions,
        push_enabled: preferences.push_enabled
      }
    }, status: :ok
  end

  def update
    preferences = NotificationPreference.find_or_initialize_by(
      user_id: @user.id
    )

    preferences.order_updates =
      params[:order_updates] unless params[:order_updates].nil?

    preferences.promotions =
      params[:promotions] unless params[:promotions].nil?

    preferences.push_enabled =
      params[:push_enabled] unless params[:push_enabled].nil?

    if preferences.save
      render json: {
        success: true,
        message: "Notification preferences updated successfully",
        data: {
          order_updates: preferences.order_updates,
          promotions: preferences.promotions,
          push_enabled: preferences.push_enabled
        }
      }, status: :ok
    else
      render json: {
        success: false,
        message: preferences.errors.full_messages.join(", ")
      }, status: :unprocessable_entity
    end
  end

  private

  def find_user
    @user = ::User.find_by(id: params[:user_id])

    unless @user
      render json: {
        success: false,
        message: "User not found"
      }, status: :not_found
    end
  end
end
