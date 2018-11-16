class CreateCandidateVacancyStages < ActiveRecord::Migration[5.0]
  def change
    create_table :candidate_vacancy_stages do |t|
      t.references :candidate, foreign_key: true
      t.references :vacancy_stage, foreign_key: true

      t.timestamps
    end
  end
end
