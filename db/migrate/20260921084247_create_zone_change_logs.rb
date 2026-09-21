class CreateZoneChangeLogs < ActiveRecord::Migration[8.0]
  def change
    create_table :zone_change_logs do |t|
      t.integer :zone_id
      t.string :action
      t.jsonb :changes_data
      t.integer :changed_by

      t.timestamps
    end
  end
end
