class AddAgentAndStatusTimestampsToOrders < ActiveRecord::Migration[8.0]
  def change
    add_column :orders, :agent_id, :integer
    add_column :orders, :accepted_at, :datetime
    add_column :orders, :rejected_at, :datetime
  end
end
