class AddPackageDetailsToOrders < ActiveRecord::Migration[8.0]
  def change
    add_column :orders, :package_type, :string
    add_column :orders, :package_size, :string
    add_column :orders, :package_value, :decimal
    add_column :orders, :package_contents, :text
  end
end
