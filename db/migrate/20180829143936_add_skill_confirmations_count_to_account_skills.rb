class AddSkillConfirmationsCountToAccountSkills < ActiveRecord::Migration[5.2]
  def change
    # add_column :account_skills, :skill_confirmations_count, :integer, default: 0
    remove_column :skills, :skill_confirmations_count, :integer, default: 0
  end
end
