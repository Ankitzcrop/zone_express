class AddServiceCategoryToOrders < ActiveRecord::Migration[8.0]
  def change
    add_column :orders, :service_category, :string
    add_column :orders, :service_id, :string
  end
end
