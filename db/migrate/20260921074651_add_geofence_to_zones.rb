class AddGeofenceToZones < ActiveRecord::Migration[8.0]
  def change

    add_column :zones, :boundary, :jsonb

    add_column :zones, :supported_pincodes, :jsonb

    add_column :zones, :operating_hours, :jsonb

    add_column :zones, :service_restrictions, :jsonb

    add_column :zones, :require_exact_pincode, :boolean

    execute <<~SQL
      ALTER TABLE zones
      ADD COLUMN geofence geometry(Geometry, 4326)
    SQL

  end
end
