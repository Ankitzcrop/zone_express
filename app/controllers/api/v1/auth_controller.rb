class Api::V1::AuthController < ApplicationController
  skip_before_action :verify_authenticity_token

  def send_otp
    user = User.find_or_create_by!(
      phone_number: params[:phone_number],
      country_code: params[:country_code]
    )

    otp = rand(100000..999999).to_s

    user.update!(
      otp: otp,
      otp_sent_at: Time.current
    )

    Rails.logger.info "OTP for #{user.phone_number}: #{otp}"

    render json: { message: "OTP sent successfully" }, status: :ok
  end

  def verify_otp
    user = User.find_by(
      phone_number: params[:phone_number],
      country_code: params[:country_code]
    )

    if user.present? &&
       user.otp == params[:otp] &&
       user.otp_sent_at > 5.minutes.ago

      user.update!(otp: nil, otp_sent_at: nil)

      token = encode_token(user_id: user.id)

      render json: {
        message: "Login successful",
        token: token,
        user_id: user.id
      }, status: :ok
    else
      render json: { error: "Invalid or expired OTP" }, status: :unprocessable_entity
    end
  end

  private

  def encode_token(payload)
    payload[:exp] = 24.hours.from_now.to_i
    JWT.encode(payload, Rails.application.secret_key_base, 'HS256')
  end
end
