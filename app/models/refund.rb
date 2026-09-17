class Refund < ApplicationRecord
  belongs_to :order

  enum :status, {
    no_refund: 0,
    requested: 1,
    processing: 2,
    completed: 3,
    rejected: 4
  }
end
