class ChangeProfileProjectToAccountProjectInWorkPeriod < ActiveRecord::Migration[5.2]
  def change
    remove_foreign_key :project_work_periods, :profile_projects
    rename_column :project_work_periods, :profile_project_id, :account_project_id
  end
end
