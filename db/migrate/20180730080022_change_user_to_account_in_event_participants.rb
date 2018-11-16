class ChangeUserToAccountInEventParticipants < ActiveRecord::Migration[5.2]
  def change
    remove_foreign_key :event_participants, :users
    rename_column :event_participants, :user_id, :account_id
  end
end
