class ChangePackageContentsToArrayInOrders < ActiveRecord::Migration[8.0]
  def change
    remove_column :orders, :package_contents
    add_column :orders, :package_contents, :string, array: true, default: []
  end
end
