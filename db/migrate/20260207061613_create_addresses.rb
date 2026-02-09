class CreateAddresses < ActiveRecord::Migration[8.0]
  def change
    create_table :addresses do |t|
      t.references :user, null: false, foreign_key: true

      t.string :name
      t.string :mobile
      t.string :flat
      t.string :area
      t.string :pincode
      t.string :city
      t.string :state
      t.string :address_type   # pickup / delivery
      t.boolean :default, default: false

      t.timestamps
    end
  end
end
