class ChangeUserToAccountInSurveyParticipants < ActiveRecord::Migration[5.2]
  def change
    remove_foreign_key :survey_participants, :users
    rename_column :survey_participants, :user_id, :account_id
  end
end
