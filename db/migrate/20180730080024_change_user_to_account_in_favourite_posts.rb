class ChangeUserToAccountInFavouritePosts < ActiveRecord::Migration[5.2]
  def change
    remove_foreign_key :favorite_posts, :profiles
    rename_column :favorite_posts, :profile_id, :account_id
  end
end
