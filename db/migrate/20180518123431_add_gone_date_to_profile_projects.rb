class AddGoneDateToProfileProjects < ActiveRecord::Migration[5.0]
  def change
    add_column :profile_projects, :gone_date, :date
  end
end
