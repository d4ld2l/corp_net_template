class AddProfilesCountToProjects < ActiveRecord::Migration[5.0]
  def change
    add_column :projects, :profile_projects_count, :integer, default: 0
  end
end
