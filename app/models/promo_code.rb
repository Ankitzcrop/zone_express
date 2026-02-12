class PromoCode < ApplicationRecord
  has_many :orders
  validates :code, presence: true, uniqueness: true
end
