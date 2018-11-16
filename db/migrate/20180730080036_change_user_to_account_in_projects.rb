class ChangeUserToAccountInProjects < ActiveRecord::Migration[5.2]
  def change
    rename_column :projects, :profile_projects_count, :account_projects_count
  end
end
