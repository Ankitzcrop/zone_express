class CreateFaqs < ActiveRecord::Migration[8.0]
  def change
    create_table :faqs do |t|
      t.string :category
      t.text :question
      t.text :answer

      t.timestamps
    end
  end
end
