class RenameManagerInProjects < ActiveRecord::Migration[5.0]
  def up
    rename_column :projects, :manager, :manager_id
    change_column :projects, :manager_id, :integer, foreign_key: true, index: true
  end

  def down
    change_column :projects, :manager_id, :integer, foreign_key: false, index: false
    rename_column :projects, :manager_id, :manager
  end

  def data
    Project.all.each do |project|
      project.update(manager_id: Profile.find_by_user_id(project.manager_id)&.id)
    end
  end
end
