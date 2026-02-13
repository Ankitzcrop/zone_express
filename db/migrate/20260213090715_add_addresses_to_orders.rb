class AddAddressesToOrders < ActiveRecord::Migration[8.0]
  def change
    add_column :orders, :pickup_address_id, :integer
    add_column :orders, :delivery_address_id, :integer
  end
end
