class AddStatusToProfileProjects < ActiveRecord::Migration[5.0]
  def change
    add_column :profile_projects, :status, :string
  end
end
