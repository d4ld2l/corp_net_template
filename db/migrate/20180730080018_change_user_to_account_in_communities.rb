class ChangeUserToAccountInCommunities < ActiveRecord::Migration[5.2]
  def change
    remove_foreign_key :communities, :users
    rename_column :communities, :user_id, :account_id
  end
end
