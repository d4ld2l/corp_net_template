class ChangeUserToAccountInNewsitems < ActiveRecord::Migration[5.2]
  def change
    remove_foreign_key :news_items, :users
    rename_column :news_items, :user_id, :account_id
  end
end
