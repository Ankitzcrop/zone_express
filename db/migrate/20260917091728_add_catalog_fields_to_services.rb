class AddCatalogFieldsToServices < ActiveRecord::Migration[8.0]
  def change
    add_column :services, :service_type, :string
    add_column :services, :icon_url, :string
  end
end
