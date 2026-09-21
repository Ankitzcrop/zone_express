class Api::V1::ServiceabilityController < ApplicationController
  def show
    latitude = params[:latitude]
    longitude = params[:longitude]
    pincode = params[:pincode].to_s.strip

    coordinates_provided = latitude.present? && longitude.present?

    if coordinates_provided
      lat = latitude.to_f
      lon = longitude.to_f

      unless valid_coordinates?(lat, lon)
        return render_result(
          false,
          nil,
          nil,
          nil,
          false,
          "INVALID_COORDINATES",
          "Invalid latitude or longitude."
        )
      end

      result = check_by_geofence(lat, lon, pincode)

      return render_result(**result)
    end

    if pincode.present?
      result = check_by_pincode(pincode)

      return render_result(**result)
    end

    render_result(
      false,
      nil,
      nil,
      nil,
      false,
      "MISSING_LOCATION",
      "Latitude/longitude or pincode is required."
    )
  end

  private

  def check_by_geofence(latitude, longitude, pincode)
    point = "ST_SetSRID(ST_Point(#{longitude}, #{latitude}), 4326)"

    zones = Zone.where(active: true)

    matched_zones = zones.where(
      "geofence IS NOT NULL AND ST_Contains(geofence, #{point})"
    )

    if matched_zones.empty?
      return {
        serviceable: false,
        zone_id: nil,
        zone_name: nil,
        match_method: nil,
        pincode_match: false,
        reason_code: "OUTSIDE_SERVICE_AREA",
        message: "Sorry, Zone Express does not deliver to this location yet."
      }
    end

    if matched_zones.count > 1
      return {
        serviceable: false,
        zone_id: nil,
        zone_name: nil,
        match_method: "geofence",
        pincode_match: false,
        reason_code: "OVERLAPPING_ZONES",
        message: "Multiple service zones match this location."
      }
    end

    zone = matched_zones.first

    pincode_match =
      pincode.blank? || zone.supported_pincode?(pincode)

    if zone.require_exact_pincode && pincode.present? && !pincode_match
      return {
        serviceable: false,
        zone_id: zone.id,
        zone_name: zone.name,
        match_method: "geofence",
        pincode_match: false,
        reason_code: "PINCODE_MISMATCH",
        message: "The pincode does not match the selected service zone."
      }
    end

    {
      serviceable: true,
      zone_id: zone.id,
      zone_name: zone.name,
      match_method: "geofence",
      pincode_match: pincode_match,
      reason_code: pincode_match ? "SERVICEABLE" : "PINCODE_MISMATCH",
      message: pincode_match ?
        "The location is within a Zone Express service area." :
        "Location is serviceable, but the pincode does not match the zone."
    }
  end

  def check_by_pincode(pincode)
    zone = Zone.active.find do |current_zone|
      current_zone.supported_pincode?(pincode)
    end

    unless zone
      return {
        serviceable: false,
        zone_id: nil,
        zone_name: nil,
        match_method: "pincode",
        pincode_match: false,
        reason_code: "PINCODE_NOT_FOUND",
        message: "The provided pincode is not serviceable."
      }
    end

    {
      serviceable: true,
      zone_id: zone.id,
      zone_name: zone.name,
      match_method: "pincode",
      pincode_match: true,
      reason_code: "SERVICEABLE",
      message: "The pincode is within a Zone Express service area."
    }
  end

  def valid_coordinates?(latitude, longitude)
    latitude.between?(-90.0, 90.0) &&
      longitude.between?(-180.0, 180.0)
  end

  def render_result(
    serviceable:,
    zone_id:,
    zone_name:,
    match_method:,
    pincode_match:,
    reason_code:,
    message:
  )
    render json: {
      success: true,
      data: {
        serviceable: serviceable,
        zone_id: zone_id,
        zone_name: zone_name,
        match_method: match_method,
        pincode_match: pincode_match,
        reason_code: reason_code,
        message: message
      }
    }
  end
end
