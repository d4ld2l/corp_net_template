class ChangeUserToAccountInSkillConfirmations < ActiveRecord::Migration[5.2]
  def change
    remove_foreign_key :skill_confirmations, :profiles
    rename_column :skill_confirmations, :profile_id, :account_id
  end
end
