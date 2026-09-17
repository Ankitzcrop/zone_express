class CreateOrderRatings < ActiveRecord::Migration[8.0]
  def change
    create_table :order_ratings do |t|
      t.references :order, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.integer :stars
      t.text :comment

      t.timestamps
    end
  end
end
