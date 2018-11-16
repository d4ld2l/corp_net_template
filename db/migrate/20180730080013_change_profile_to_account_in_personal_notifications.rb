class ChangeProfileToAccountInPersonalNotifications < ActiveRecord::Migration[5.2]
  def change
    remove_foreign_key :personal_notifications, :profiles
    rename_column :personal_notifications, :profile_id, :account_id
  end
end
