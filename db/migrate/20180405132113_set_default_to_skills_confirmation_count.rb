class SetDefaultToSkillsConfirmationCount < ActiveRecord::Migration[5.0]
  def change
    change_column :skills, :skill_confirmations_count, :integer, default: 0
  end
end
