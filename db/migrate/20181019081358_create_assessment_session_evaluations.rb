class CreateAssessmentSessionEvaluations < ActiveRecord::Migration[5.2]
  def change
    create_table :assessment_session_evaluations do |t|
      t.belongs_to :assessment_session, foreign_key: true
      t.belongs_to :account, foreign_key: true
      t.boolean :done, default: false, null: false

      t.timestamps
    end
  end
end
