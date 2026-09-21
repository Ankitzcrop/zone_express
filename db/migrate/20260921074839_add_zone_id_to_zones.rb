class AddZoneIdToZones < ActiveRecord::Migration[8.0]
  def change
    add_column :zones, :zone_id, :string
  end
end
