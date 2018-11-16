class AddProfileAndProjectRefsToSkills < ActiveRecord::Migration[5.0]
  def change
    add_column :skills, :profile_id, :integer, index: true
    add_column :skills, :project_id, :integer, index: true
  end
end
