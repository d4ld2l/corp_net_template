class CreateSurveyAnswers < ActiveRecord::Migration[5.0]
  def change
    create_table :survey_answers do |t|
      t.belongs_to :survey_result, foreign_key: { on_delete: :cascade }
      t.belongs_to :question, foreign_key: { on_delete: :cascade }
      t.jsonb :answers, default: {}

      t.timestamps
    end
  end
end
