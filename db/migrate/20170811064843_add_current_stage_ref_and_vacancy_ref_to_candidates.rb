class AddCurrentStageRefAndVacancyRefToCandidates < ActiveRecord::Migration[5.0]
  def change
    add_column :candidates, :current_vacancy_stage_id, :integer, foreign_key: true
    add_column :candidates, :vacancy_id, :integer, foreign_key: true
  end
end
