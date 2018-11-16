class AddCountersToAssessmentSessions < ActiveRecord::Migration[5.2]
  def change
    add_column :assessment_sessions, :participants_count, :integer, default: 0
    add_column :assessment_sessions, :evaluations_count, :integer, default: 0
  end
end
