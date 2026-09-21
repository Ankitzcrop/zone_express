class NotificationPreference < ApplicationRecord
  belongs_to :user
  validates :order_updates, inclusion: { in: [true, false] }
  validates :promotions, inclusion: { in: [true, false] }
  validates :push_enabled, inclusion: { in: [true, false] }
end
