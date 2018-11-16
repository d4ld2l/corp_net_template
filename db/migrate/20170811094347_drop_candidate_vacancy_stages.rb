class DropCandidateVacancyStages < ActiveRecord::Migration[5.0]
  def change
    drop_table :candidate_vacancy_stages
  end
end