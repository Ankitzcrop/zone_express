class AddScheduleToOrders < ActiveRecord::Migration[8.0]
  def change
    add_column :orders, :pickup_date, :date
    add_column :orders, :pickup_time, :string
  end
end
