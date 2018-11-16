class ChangeUserToAccountInLikes < ActiveRecord::Migration[5.2]
  def change
    remove_foreign_key :likes, :profiles
    rename_column :likes, :profile_id, :account_id
  end
end
