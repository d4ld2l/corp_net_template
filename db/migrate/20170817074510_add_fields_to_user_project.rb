class AddFieldsToUserProject < ActiveRecord::Migration[5.0]
  def change
    add_reference :user_projects, :project_role, foreign_key: true
    add_column :user_projects, :start_date, :date
    add_column :user_projects, :end_date, :date
    add_column :user_projects, :skills, :json
    add_column :user_projects, :duties, :text
    add_column :user_projects, :feedback, :text
    add_column :user_projects, :rating, :integer
  end
end
