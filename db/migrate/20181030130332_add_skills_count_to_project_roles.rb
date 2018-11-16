class AddSkillsCountToProjectRoles < ActiveRecord::Migration[5.2]
  def change
    add_column :project_roles, :skills_count, :integer, default: 0, null: false
  end
end
