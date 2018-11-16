class CreateProjectRolesAgain < ActiveRecord::Migration[5.2]
  def change
    create_table :project_roles do |t|
      t.string :name, null: false, index: true
      t.string :description

      t.timestamps
    end
    add_reference :project_roles, :company, index: true
  end
end
