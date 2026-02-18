class AddDimensionsAndWeightToOrders < ActiveRecord::Migration[8.0]
  def change
    add_column :orders, :length, :float
    add_column :orders, :breadth, :float
    add_column :orders, :height, :float
    add_column :orders, :weight, :float
  end
end
