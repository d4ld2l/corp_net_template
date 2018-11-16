class ChangeUserToAccountInMentions < ActiveRecord::Migration[5.2]
  def change
    remove_foreign_key :mentions, :profiles
    rename_column :mentions, :profile_id, :account_id
  end
end
