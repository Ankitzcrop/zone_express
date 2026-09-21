class CreateZones < ActiveRecord::Migration[8.0]
  def change
    create_table :zones do |t|
      t.string :name
      t.string :pincode
      t.decimal :latitude
      t.decimal :longitude
      t.decimal :radius
      t.boolean :active

      t.timestamps
    end
  end
end
