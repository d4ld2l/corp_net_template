class CreateAccountPhones < ActiveRecord::Migration[5.2]
  def change
    create_table :account_phones do |t|
      t.string :number
      t.boolean :preferable
      t.references :account, foreign_key: true
      t.integer :kind
      t.boolean :whatsapp
      t.boolean :telegram
      t.boolean :viber

      t.timestamps
    end
  end
end
