class User < ApplicationRecord
  validates :phone_number, presence: true
  validates :country_code, presence: true
  validates :phone_number, uniqueness: {
    scope: :country_code,
    message: "already exists"
  }
  has_many :addresses
  has_many :orders
  has_many :support_tickets, dependent: :destroy

  def initials
    return "" if name.blank?

    name.split.map(&:first).join.upcase.first(2)
  end
end
