class AddDepartmentToProject < ActiveRecord::Migration[5.0]
  def change
    add_reference :projects, :department, foreign_key: true
  end
end
