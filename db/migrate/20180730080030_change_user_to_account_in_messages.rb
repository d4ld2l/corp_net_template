class ChangeUserToAccountInMessages < ActiveRecord::Migration[5.2]
  def change
    remove_foreign_key :messages, :users
    rename_column :messages, :user_id, :account_id
  end
end
