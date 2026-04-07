class CreateSupportTickets < ActiveRecord::Migration[8.0]
  def change
    create_table :support_tickets do |t|
      t.references :user, null: false, foreign_key: true
      t.string :ticket_number, null: false
      t.integer :status, null: false, default: 0
      t.string :subject
      t.text :problem_description, null: false

      t.timestamps
    end

    add_index :support_tickets, :ticket_number, unique: true
    add_index :support_tickets, :status
  end
end
