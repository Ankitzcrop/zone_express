class Order < ApplicationRecord
  belongs_to :user
  belongs_to :delivery_type, optional: true
  belongs_to :promo_code, optional: true
  belongs_to :service, optional: true
  # validates :package_type, presence: true
  # validates :package_size, presence: true
  before_create :generate_tracking_id
  belongs_to :pickup_address, class_name: "Address", optional: true
  belongs_to :delivery_address, class_name: "Address", optional: true
  belongs_to :receiver, class_name: "User", optional: true
  has_many :order_trackings, dependent: :destroy
  after_update :create_tracking_record, if: :saved_change_to_status?
  
  enum :status, {
    draft: 0,
    package_added: 1,
    scheduled: 2,
    confirmed: 3,
    accepted: 4,
    rejected: 5,
    cancelled: 6,
    reschedule: 7,
    picked_up: 8,
    in_transit: 9,
    delivered: 10
  }

  def calculate_total
    base_price = delivery_type&.price || 0

    if promo_code.present?
      discount = (base_price * promo_code.discount_percentage) / 100
      self.total_amount = base_price - discount
    else
      self.total_amount = base_price
    end

    save
  end
  
  private

  def generate_tracking_id
    self.tracking_id = "ZX#{SecureRandom.hex(4).upcase}"
  end

  def create_tracking_record
    tracking_status = map_tracking_status

    return if tracking_status.blank?

    order_trackings.create!(
      status: tracking_status,
      timestamp: Time.current,
      note: "Order status updated to #{tracking_status.to_s.humanize}"
    )
  end

  def map_tracking_status
    case status
    when "draft", "package_added", "scheduled", "confirmed", "accepted", "reschedule"
      :booked
    when "picked_up"
      :picked_up
    when "in_transit"
      :in_transit
    when "delivered"
      :delivered
    when "rejected", "cancelled"
      :cancelled
    else
      nil
    end
  end
end
