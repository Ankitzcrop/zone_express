class Address < ApplicationRecord
  belongs_to :user
  before_save :set_coordinates, if: :should_geocode?

  private

  def should_geocode?
    latitude.blank? || longitude.blank? ||
      will_save_change_to_area? ||
      will_save_change_to_city? ||
      will_save_change_to_state? ||
      will_save_change_to_pincode?
  end

  def set_coordinates
    search_queries = [
      [area, city, state, pincode, "India"].compact.reject(&:blank?).join(", "),
      [city, state, pincode, "India"].compact.reject(&:blank?).join(", "),
      [city, state, "India"].compact.reject(&:blank?).join(", ")
    ]

    search_queries.each do |query|
      result = Geocoder.search(query).first
      if result.present?
        self.latitude = result.latitude
        self.longitude = result.longitude
        break
      end
    end
  end
end
