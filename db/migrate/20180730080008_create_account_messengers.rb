class CreateAccountMessengers < ActiveRecord::Migration[5.2]
  def change
    create_table :account_messengers do |t|
      t.integer :name
      t.references :account, foreign_key: true
      t.jsonb :phones

      t.timestamps
    end
  end
end
