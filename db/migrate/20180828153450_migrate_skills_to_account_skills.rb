class MigrateSkillsToAccountSkills < ActiveRecord::Migration[5.2]
  def change
    remove_column :skills, :account_id, :integer, index: true
    remove_column :skill_confirmations, :skill_id, :integer, index: true
  end
end
