class Api::V1::Admin::ZonesController < ApplicationController
  skip_before_action :verify_authenticity_token
  def index
    zones = Zone.order(created_at: :desc)

    render json: {
      success: true,
      data: zones.map { |zone| zone_response(zone) }
    }
  end

  def show
    zone = Zone.find(params[:id])

    render json: {
      success: true,
      data: zone_response(zone)
    }
  end

  def create
    zone = Zone.new(zone_params)

    if zone.save
      save_geofence(zone)

      create_change_log(zone, "created")

      render json: {
        success: true,
        message: "Zone created successfully",
        data: zone_response(zone)
      }, status: :created
    else
      render json: {
        success: false,
        message: zone.errors.full_messages.join(", ")
      }, status: :unprocessable_entity
    end
  end

  def update
    zone = Zone.find(params[:id])

    old_values = zone.attributes

    if zone.update(zone_params)
      save_geofence(zone) if params[:geofence].present?

      create_change_log(
        zone,
        "updated",
        old_values
      )

      render json: {
        success: true,
        message: "Zone updated successfully",
        data: zone_response(zone)
      }
    else
      render json: {
        success: false,
        message: zone.errors.full_messages.join(", ")
      }, status: :unprocessable_entity
    end
  end

  def destroy
    zone = Zone.find(params[:id])

    create_change_log(zone, "deleted")
    zone.destroy

    render json: {
      success: true,
      message: "Zone deleted successfully"
    }
  end

  def activate
    zone = Zone.find(params[:id])

    zone.update!(active: true)
    create_change_log(zone, "activated")

    render json: {
      success: true,
      message: "Zone activated successfully",
      data: zone_response(zone)
    }
  end

  def deactivate
    zone = Zone.find(params[:id])

    zone.update!(active: false)
    create_change_log(zone, "deactivated")

    render json: {
      success: true,
      message: "Zone deactivated successfully",
      data: zone_response(zone)
    }
  end

  def change_logs
    zone = Zone.find_by(id: params[:id])

    unless zone
      return render json: {
        success: false,
        message: "Zone not found",
        data: []
      }, status: :not_found
    end

    render json: {
      success: true,
      message: "Zone change logs fetched successfully",
      data: zone.zone_change_logs.order(created_at: :desc)
    }
  end

  private

  def zone_params
    params.require(:zone).permit(
      :zone_id,
      :name,
      :pincode,
      :latitude,
      :longitude,
      :radius,
      :active,
      :require_exact_pincode,
      supported_pincodes: [],
      operating_hours: {},
      service_restrictions: {}
    )
  end

  def create_change_log(zone, action, previous_values = nil)
    ZoneChangeLog.create!(
      zone_id: zone.id,
      action: action,
      changes_data: {
        previous_values: previous_values,
        current_values: zone.attributes
      },
      changed_by: params[:admin_id]
    )
  end

  def zone_response(zone)
    {
      zone_id: zone.zone_id,
      zone_name: zone.name,
      active: zone.active,
      supported_pincodes: zone.supported_pincodes,
      operating_hours: zone.operating_hours,
      service_restrictions: zone.service_restrictions,
      require_exact_pincode: zone.require_exact_pincode
    }
  end

  def save_geofence(zone)
    geojson = params[:geofence]
    return if geojson.blank?

    geometry = geojson["geometry"] || geojson
    return if geometry.blank?

    type = geometry["type"]
    coordinates = geometry["coordinates"]

    return if coordinates.blank?

    wkt =
      case type
      when "Polygon"
        polygon_to_wkt(coordinates)
      when "MultiPolygon"
        multipolygon_to_wkt(coordinates)
      end

    return if wkt.blank?

    sql = ActiveRecord::Base.sanitize_sql_array([
      "UPDATE zones SET geofence = ST_GeomFromText(?, 4326) WHERE id = ?",
      wkt,
      zone.id
    ])

    ActiveRecord::Base.connection.execute(sql)
  end

  def polygon_to_wkt(coordinates)
    rings = coordinates.map do |ring|
      points = ring.map { |point| "#{point[0]} #{point[1]}" }
      "(#{points.join(", ")})"
    end

    "POLYGON(#{rings.join(", ")})"
  end

  def multipolygon_to_wkt(coordinates)
    polygons = coordinates.map do |polygon|
      rings = polygon.map do |ring|
        points = ring.map { |point| "#{point[0]} #{point[1]}" }
        "(#{points.join(", ")})"
      end

      "(#{rings.join(", ")})"
    end

    "MULTIPOLYGON(#{polygons.join(", ")})"
  end

  def polygon_to_wkt(coordinates)
    rings = coordinates.map do |ring|
      points = ring.map do |point|
        "#{point[0]} #{point[1]}"
      end

      "(#{points.join(", ")})"
    end

    "POLYGON(#{rings.join(", ")})"
  end
end
