class DeleteTemplateStageGroups < ActiveRecord::Migration[5.0]
  def change
    drop_table :template_stage_groups
  end
end
