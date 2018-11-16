class AddFieldsToAssessmentSessions < ActiveRecord::Migration[5.2]
  def change
    add_column :assessment_sessions, :obvious_fortes, :string
    add_column :assessment_sessions, :hidden_fortes, :string
    add_column :assessment_sessions, :growth_direction, :string
    add_column :assessment_sessions, :blind_spots, :string
    add_column :assessment_sessions, :conclusion, :string
  end
end
