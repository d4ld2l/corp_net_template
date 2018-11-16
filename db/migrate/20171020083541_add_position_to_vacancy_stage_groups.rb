class AddPositionToVacancyStageGroups < ActiveRecord::Migration[5.0]
  def change
    add_column :vacancy_stage_groups, :position, :integer
  end
end
