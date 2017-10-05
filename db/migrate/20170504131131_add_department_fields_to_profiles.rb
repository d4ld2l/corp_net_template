class AddDepartmentFieldsToProfiles < ActiveRecord::Migration[5.0]
  def change
    add_reference :profiles, :manager, index: true
    add_column :profiles, :department_code, :string
    add_column :profiles, :position_code, :string, index: true
    add_column :profiles, :department_head, :boolean
  end
end
