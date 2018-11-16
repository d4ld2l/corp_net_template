class ChangeUserToAccountInComments < ActiveRecord::Migration[5.2]
  def change
    remove_foreign_key :comments, :users
    rename_column :comments, :profile_id, :account_id
  end
end
