class RemoveOrganizationUnitFromLegalUnitEmployeePosition < ActiveRecord::Migration[5.0]
  def change
    remove_column :legal_unit_employee_positions, :organization_unit, :string
  end
end
