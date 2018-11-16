class AddStructureUnitToLegalUnitEmployees < ActiveRecord::Migration[5.0]
  def change
    add_column :legal_unit_employees, :structure_unit, :string
  end
end
