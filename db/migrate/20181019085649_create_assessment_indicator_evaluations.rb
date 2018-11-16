class CreateAssessmentIndicatorEvaluations < ActiveRecord::Migration[5.2]
  def change
    create_table :assessment_indicator_evaluations do |t|
      t.belongs_to :assessment_skill_evaluation, foreign_key: true, index: { name: :index_assessment_indicator_evaluations_on_skill_evaluation_id}
      t.belongs_to :indicator, foreign_key: true
      t.integer :rating_scale, default: 0, null: false
      t.integer :rating

      t.timestamps
    end
  end
end
