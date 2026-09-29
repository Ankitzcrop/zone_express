class User < ApplicationRecord
  has_secure_password validations: false
  validates :phone_number, presence: true
  validates :country_code, presence: true
  validates :phone_number, uniqueness: {
    scope: :country_code,
    message: "already exists"
  }
  has_many :addresses, dependent: :destroy
  has_many :orders, dependent: :destroy
  has_many :support_tickets, dependent: :destroy
  has_one :agent_profile, dependent: :destroy
  has_many :order_ratings, dependent: :destroy
  has_many :devices, dependent: :destroy
  has_one :notification_preference, dependent: :destroy

  enum :role, {
    user: 0,
    merchant: 1,
    admin: 2
  }

  def initials
    return "" if name.blank?

    name.split.map(&:first).join.upcase.first(2)
  end
end
