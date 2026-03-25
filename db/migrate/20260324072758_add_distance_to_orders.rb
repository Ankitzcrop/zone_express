class AddDistanceToOrders < ActiveRecord::Migration[8.0]
  def change
    add_column :orders, :distance, :float
  end
end
