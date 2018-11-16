class AddCommentsCountToCandidateVacancy < ActiveRecord::Migration[5.0]
  def change
    add_column :candidate_vacancies, :comments_count, :integer
  end
end
