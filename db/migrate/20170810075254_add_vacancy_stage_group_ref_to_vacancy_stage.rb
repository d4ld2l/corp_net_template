class AddVacancyStageGroupRefToVacancyStage < ActiveRecord::Migration[5.0]
  def change
    add_column :vacancy_stages, :vacancy_stage_group_id, :integer
  end
end
