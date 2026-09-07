class AddRescheduledDateToOrders < ActiveRecord::Migration[8.0]
  def change
    add_column :orders, :rescheduled_date, :date
  end
end
