class AddReceiverIdToOrders < ActiveRecord::Migration[8.0]
  def change
    add_column :orders, :receiver_id, :integer
  end
end
