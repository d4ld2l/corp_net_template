class ChangeUserToAccountInFavouriteDiscussions < ActiveRecord::Migration[5.2]
  def change
    remove_foreign_key :favorite_discussions, :profiles
    rename_column :favorite_discussions, :profile_id, :account_id
  end
end
