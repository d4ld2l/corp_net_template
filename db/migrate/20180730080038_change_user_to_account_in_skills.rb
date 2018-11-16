class ChangeUserToAccountInSkills < ActiveRecord::Migration[5.2]
  def change
    rename_column :skills, :profile_id, :account_id
  end
end
