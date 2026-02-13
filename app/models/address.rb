class Address < ApplicationRecord
  belongs_to :user
    enum :address_type, { pickup: 0, delivery: 1 }
end
