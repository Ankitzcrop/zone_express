class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  private

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
