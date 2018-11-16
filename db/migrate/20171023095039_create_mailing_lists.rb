class CreateMailingLists < ActiveRecord::Migration[5.0]
  def change
    create_table :mailing_lists do |t|
      t.string :name, null: false
      t.text :description, null: false, default: ''
      t.integer :user_id, foreign_key: true

      t.timestamps
    end
  end
end
