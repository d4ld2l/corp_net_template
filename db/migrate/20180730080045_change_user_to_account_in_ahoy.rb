class ChangeUserToAccountInAhoy < ActiveRecord::Migration[5.2]
  def change
    rename_column :ahoy_visits, :user_id, :account_id
    rename_column :ahoy_events, :user_id, :account_id
  end
end
