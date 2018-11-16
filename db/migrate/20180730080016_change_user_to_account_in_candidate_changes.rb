class ChangeUserToAccountInCandidateChanges < ActiveRecord::Migration[5.2]
  def change
    remove_foreign_key :candidate_changes, :users
    rename_column :candidate_changes, :user_id, :account_id
  end
end
