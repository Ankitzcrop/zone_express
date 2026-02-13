class Order < ApplicationRecord
  belongs_to :user
  belongs_to :delivery_type, optional: true
  belongs_to :promo_code, optional: true
  # validates :package_type, presence: true
  # validates :package_size, presence: true
  before_create :generate_tracking_id
  belongs_to :pickup_address, class_name: "Address", optional: true
  belongs_to :delivery_address, class_name: "Address", optional: true
  enum :status, {
    draft: 0,
    package_added: 1,
    scheduled: 2,
    confirmed: 3
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
end
