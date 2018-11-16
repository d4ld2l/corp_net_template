class RemoveCurrentVacancyStageFromCandidates < ActiveRecord::Migration[5.0]
  def change
    remove_column :candidates, :current_vacancy_stage_id
  end
end
