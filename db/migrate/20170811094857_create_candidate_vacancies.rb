class CreateCandidateVacancies < ActiveRecord::Migration[5.0]
  def change
    create_table :candidate_vacancies do |t|
      t.references :candidate, foreign_key: true
      t.references :vacancy, foreign_key: true
      t.integer :current_vacancy_stage_id

      t.timestamps
    end
  end
end
