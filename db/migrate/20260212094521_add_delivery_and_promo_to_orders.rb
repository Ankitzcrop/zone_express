class AddDeliveryAndPromoToOrders < ActiveRecord::Migration[8.0]
  def change
    add_reference :orders, :delivery_type, null: false, foreign_key: true
    add_reference :orders, :promo_code, null: false, foreign_key: true
    add_column :orders, :total_amount, :decimal
  end
end
