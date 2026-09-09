class OrderTracking < ApplicationRecord
  belongs_to :order
  
  enum :status, {
    booked: 0,
    picked_up: 1,
    in_transit: 2,
    delivered: 3,
    cancelled: 4
  }
end
