class CreateAssessmentSkillEvaluations < ActiveRecord::Migration[5.2]
  def change
    create_table :assessment_skill_evaluations do |t|
      t.belongs_to :assessment_session_evaluation, foreign_key: true, index: {name: :index_assessment_skill_evaluations_on_session_evaluations_id}
      t.belongs_to :skill, foreign_key: true
      t.string :comment

      t.timestamps
    end
  end
end
