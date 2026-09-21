class CreateNotificationPreferences < ActiveRecord::Migration[8.0]
  def change
    create_table :notification_preferences do |t|
      t.references :user, null: false, foreign_key: true
      t.boolean :order_updates
      t.boolean :promotions
      t.boolean :push_enabled

      t.timestamps
    end
  end
end
