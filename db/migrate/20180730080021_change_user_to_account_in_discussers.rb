class ChangeUserToAccountInDiscussers < ActiveRecord::Migration[5.2]
  def change
    remove_foreign_key :discussers, :profiles
    rename_column :discussers, :profile_id, :account_id
  end
end
