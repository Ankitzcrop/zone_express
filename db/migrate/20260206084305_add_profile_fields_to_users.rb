class AddProfileFieldsToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :name, :string
    add_column :users, :email, :string
    add_column :users, :gender, :string
    add_column :users, :date_of_birth, :date
    add_column :users, :emergency_contact, :string
  end
end
