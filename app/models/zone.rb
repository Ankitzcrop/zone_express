class Zone < ApplicationRecord
  validates :name, presence: true

  has_many :zone_change_logs, dependent: :destroy

  scope :active_zones, -> { where(active: true) }

  def supported_pincode?(value)
    return false if value.blank?

    pincodes = supported_pincodes || []

    case pincodes
    when Array
      pincodes.map(&:to_s).include?(value.to_s)
    when String
      pincodes.split(",").map(&:strip).include?(value.to_s)
    else
      false
    end
  end
end
