# app/controllers/api/v1/schedules_controller.rb
class Api::V1::SchedulesController < ApplicationController
  skip_before_action :verify_authenticity_token

  # 📅 Available Pickup Dates
  def available_dates
    today = Date.today

    dates = (0..2).map do |i|
      date = today + i.days
      {
        day: date.strftime("%a"),
        date: date.day,
        month: date.strftime("%b"),
        full_date: date
      }
    end

    render json: {
      success: true,
      next_slot_remaining: remaining_time,
      dates: dates
    }
  end

  # 📦 Book Pickup
  def book_pickup
    order = Order.find_by(id: params[:order_id])

    unless order
      return render json: { success: false, message: "Order not found" }
    end

    order.update(
      pickup_date: params[:pickup_date],
      pickup_time: params[:pickup_time],
      status: "scheduled"
    )

    render json: {
      success: true,
      message: "Pickup scheduled successfully",
      order: order
    }
  end

  private

  # ⏳ Remaining time calculation
  def remaining_time
    next_slot = Time.now.end_of_day
    seconds = next_slot - Time.now
    hours = (seconds / 3600).to_i
    minutes = ((seconds % 3600) / 60).to_i

    "#{hours}:#{minutes} Hrs remaining for next pickup slot"
  end
end
