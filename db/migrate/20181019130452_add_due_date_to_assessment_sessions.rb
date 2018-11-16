class AddDueDateToAssessmentSessions < ActiveRecord::Migration[5.2]
  def change
    add_column :assessment_sessions, :due_date, :date
  end
end
