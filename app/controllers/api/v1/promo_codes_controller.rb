class Api::V1::PromoCodesController < ApplicationController
  skip_before_action :verify_authenticity_token

  # 🔹 Create Promo Code
  def create
    promo = PromoCode.new(promo_params)

    if promo.save
      render json: {
        success: true,
        message: "Promo code created successfully",
        promo_code: promo
      }
    else
      render json: {
        success: false,
        errors: promo.errors.full_messages
      }
    end
  end

  # 🔹 List All Promo Codes
  def index
    promos = PromoCode.all

    render json: {
      success: true,
      promo_codes: promos
    }
  end

  private

  def promo_params
    params.permit(:code, :discount_percentage, :active)
  end
end
