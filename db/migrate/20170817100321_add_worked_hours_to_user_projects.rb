class AddWorkedHoursToUserProjects < ActiveRecord::Migration[5.0]
  def change
    add_column :user_projects, :worked_hours, :integer
  end
end
