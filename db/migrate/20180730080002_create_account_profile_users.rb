class CreateAccountProfileUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :account_profile_users do |t|
      t.integer :profile_id
      t.integer :user_id
      t.integer :account_id

      t.timestamps
    end
  end
end
