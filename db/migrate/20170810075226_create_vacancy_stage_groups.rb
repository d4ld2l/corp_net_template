class CreateVacancyStageGroups < ActiveRecord::Migration[5.0]
  def change
    create_table :template_stage_groups do |t|
      t.string :label
      t.string :color
      t.string :value

      t.timestamps
    end
  end
end
