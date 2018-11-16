class ChangeAccountIdToUserIdInAhoy < ActiveRecord::Migration[5.2]
  def change
    rename_column :ahoy_visits, :account_id, :user_id
    rename_column :ahoy_events, :account_id, :user_id
  end
end
