class AddCandidateVacanciesCountToVacancyStages < ActiveRecord::Migration[5.0]
  def change
    add_column :vacancy_stages, :candidate_vacancies_count, :integer, default: 0
  end
end
