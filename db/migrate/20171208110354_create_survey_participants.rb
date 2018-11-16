class CreateSurveyParticipants < ActiveRecord::Migration[5.0]
  def change
    create_table :survey_participants do |t|
      t.references :survey, foreign_key: true
      t.references :user, foreign_key: true
      t.index [:user_id, :survey_id]

      t.timestamps
    end
  end
end
