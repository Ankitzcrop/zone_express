class CreateOrderTrackings < ActiveRecord::Migration[8.0]
  def change
    create_table :order_trackings do |t|
      t.references :order, null: false, foreign_key: true
      t.integer :status
      t.datetime :timestamp
      t.text :note

      t.timestamps
    end
  end
end
