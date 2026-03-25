class AddDriverAmountToOrders < ActiveRecord::Migration[8.0]
  def change
    add_column :orders, :driver_amount, :decimal
  end
end
