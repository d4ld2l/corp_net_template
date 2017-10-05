class AddManagerRefToDepartments < ActiveRecord::Migration[5.0]
  def change
    add_column :departments, :manager_id, :integer, index: true
  end
end
