class ChangeManagerToManagerIdInLegalUnitEmployees < ActiveRecord::Migration[5.0]
  def change
    remove_column :legal_unit_employees, :manager
    add_column :legal_unit_employees, :manager_id, :integer
    add_foreign_key :legal_unit_employees, :profiles, column: :manager_id
  end
end
