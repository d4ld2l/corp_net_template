class ChangeUserToAccountInParticipants < ActiveRecord::Migration[5.2]
  def change
    remove_foreign_key :participants, :users
    rename_column :participants, :user_id, :account_id
  end
end
