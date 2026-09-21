class CreateDevices < ActiveRecord::Migration[8.0]
  def change
    create_table :devices do |t|
      t.references :user, null: false, foreign_key: true
      t.string :fcm_token
      t.string :platform

      t.timestamps
    end
  end
end
