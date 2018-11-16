class AddSkillConfirmationCountToSkills < ActiveRecord::Migration[5.0]
  def change
    add_column :skills, :skill_confirmations_count, :integer, index: true
  end
end
