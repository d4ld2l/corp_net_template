class DeleteUselessFieldsFromProfileProjects < ActiveRecord::Migration[5.0]
  def change
    remove_column :profile_projects, :start_date, :date
    remove_column :profile_projects, :end_date, :date
    remove_column :profile_projects, :skills, :string
    remove_column :profile_projects, :duties, :string
    remove_column :profile_projects, :project_role_id, :integer
  end
end
