class CreateDeliveryTypes < ActiveRecord::Migration[8.0]
  def change
    create_table :delivery_types do |t|
      t.string :name
      t.decimal :price
      t.string :estimated_days

      t.timestamps
    end
  end
end
