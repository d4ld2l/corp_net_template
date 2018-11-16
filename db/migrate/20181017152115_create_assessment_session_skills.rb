class CreateAssessmentSessionSkills < ActiveRecord::Migration[5.2]
  def change
    create_table :assessment_session_skills do |t|
      t.belongs_to :assessment_session, foreign_key: true
      t.belongs_to :skill, foreign_key: true

      t.timestamps
    end
  end
end
