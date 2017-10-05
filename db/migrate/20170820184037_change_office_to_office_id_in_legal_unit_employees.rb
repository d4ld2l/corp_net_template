class ChangeOfficeToOfficeIdInLegalUnitEmployees < ActiveRecord::Migration[5.0]
  def change
    remove_column :legal_unit_employees, :office, :integer
    add_reference :legal_unit_employees, :office
  end
end
