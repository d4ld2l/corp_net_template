class ChangeUserToAccountInNotifications < ActiveRecord::Migration[5.2]
  def change
    remove_foreign_key :notifications, :users
    rename_column :notifications, :user_id, :account_id
  end
end
