class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      t.string :country_code
      t.string :phone_number
      t.string :otp
      t.datetime :otp_sent_at

      t.timestamps
    end
  end
end
