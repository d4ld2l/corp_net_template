class ChangeUserToAccountInConfirmSkills < ActiveRecord::Migration[5.2]
  def change
    rename_column :confirm_skills, :user_id, :account_id
  end
end
