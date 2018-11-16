class CreateSurveyResults < ActiveRecord::Migration[5.0]
  def change
    create_table :survey_results do |t|
      t.belongs_to :survey, foreign_key: { on_delete: :cascade }
      t.belongs_to :user, foreign_key: true
      t.datetime :starts_at
      t.datetime :ends_at

      t.timestamps
    end
  end
end
