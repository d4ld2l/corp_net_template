class AddSkillsCountToAssessmentSessions < ActiveRecord::Migration[5.2]
  def change
    add_column :assessment_sessions, :skills_count, :integer, null: false, default: 0
  end
end
