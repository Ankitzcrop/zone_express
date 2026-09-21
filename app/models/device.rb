class Device < ApplicationRecord
  belongs_to :user
  validates :fcm_token, presence: true
  validates :platform, inclusion: { in: %w[android ios] }
end
