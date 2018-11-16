class AddCreatedByAndUpdatedByToProjects < ActiveRecord::Migration[5.0]
  def change
    add_column :projects, :created_by_id, :integer
    add_column :projects, :updated_by_id, :integer
  end
end
