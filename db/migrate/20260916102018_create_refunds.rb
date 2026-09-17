class CreateRefunds < ActiveRecord::Migration[8.0]
  def change
    create_table :refunds do |t|
      t.references :order, null: false, foreign_key: true
      t.integer :status
      t.decimal :amount
      t.string :currency
      t.string :refund_id
      t.datetime :requested_at
      t.datetime :completed_at

      t.timestamps
    end
  end
end
