class ChangeUserToAccountInSurveyResults < ActiveRecord::Migration[5.2]
  def change
    remove_foreign_key :survey_results, :users
    rename_column :survey_results, :user_id, :account_id
  end
end
