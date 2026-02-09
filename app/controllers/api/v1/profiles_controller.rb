# app/controllers/api/v1/profiles_controller.rb
class Api::V1::ProfilesController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :authorize_user

  # GET /api/v1/profile
  def show
    render json: profile_response(@current_user), status: :ok
  end

  # PUT /api/v1/profile
  def update
    if @current_user.update(profile_params)
      render json: {
        message: "Profile updated successfully",
        profile: profile_response(@current_user)
      }, status: :ok
    else
      render json: { errors: @current_user.errors.full_messages },
             status: :unprocessable_entity
    end
  end

  private

  def profile_params
    params.permit(
      :name,
      :email,
      :gender,
      :date_of_birth,
      :emergency_contact
    )
  end

  def profile_response(user)
    {
      name: user.name,
      phone_number: "#{user.country_code} #{user.phone_number}", # read-only
      email: user.email,
      gender: user.gender,
      date_of_birth: user.date_of_birth,
      member_since: user.created_at.strftime("%B %Y"),
      emergency_contact: user.emergency_contact
    }
  end

  # JWT Authorization
  def authorize_user
    header = request.headers['Authorization']

    if header.blank?
      return render json: { error: "Token missing" }, status: :unauthorized
    end

    token = header.split(' ').last

    begin
      decoded = JWT.decode(
        token,
        Rails.application.secret_key_base,
        true,
        algorithm: 'HS256'
      )
      @current_user = User.find(decoded[0]['user_id'])
    rescue JWT::ExpiredSignature
      render json: { error: "Token expired" }, status: :unauthorized
    rescue JWT::DecodeError
      render json: { error: "Invalid token" }, status: :unauthorized
    rescue ActiveRecord::RecordNotFound
      render json: { error: "User not found" }, status: :unauthorized
    end
  end
end
