class OrderRating < ApplicationRecord
  belongs_to :order
  belongs_to :user
  validates :stars, presence: true,
                    inclusion: { in: 1..5 }

  validates :comment, length: { maximum: 1000 }, allow_blank: true

  validates :order_id, uniqueness: {
    scope: :user_id,
    message: "has already been rated by this user"
  }
end
