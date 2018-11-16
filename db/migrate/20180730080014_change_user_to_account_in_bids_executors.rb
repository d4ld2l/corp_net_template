class ChangeUserToAccountInBidsExecutors < ActiveRecord::Migration[5.2]
  def change
    rename_column :bids_executors, :user_id, :account_id
  end
end
