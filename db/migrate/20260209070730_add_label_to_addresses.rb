class AddLabelToAddresses < ActiveRecord::Migration[8.0]
  def change
    add_column :addresses, :label, :string
  end
end
