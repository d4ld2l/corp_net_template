class ChangeUserToProfileInProjects < ActiveRecord::Migration[5.0]
  def up
    rename_table :user_projects, :profile_projects
    rename_column :profile_projects, :user_id, :profile_id
  end

  def down
    rename_column :profile_projects, :profile_id, :user_id
    rename_table :profile_projects, :user_projects
  end

  def data
    ProfileProject.all.each {|x| x.update(profile_id: Profile.find_by_user_id(x.profile_id).id)}
  end
end
