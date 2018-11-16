class CreateAccountEmails < ActiveRecord::Migration[5.2]
  def change
    create_table :account_emails do |t|
      t.string :email
      t.boolean :preferable
      t.references :account, foreign_key: true
      t.integer :kind

      t.timestamps
    end
  end
end
