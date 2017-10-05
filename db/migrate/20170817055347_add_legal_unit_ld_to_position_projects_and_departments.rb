class AddLegalUnitLdToPositionProjectsAndDepartments < ActiveRecord::Migration[5.0]
  def change
    add_reference :positions, :legal_unit, foreign_key: true
    add_reference :position_groups, :legal_unit, foreign_key: true
    add_reference :departments, :legal_unit, foreign_key: true
    add_reference :projects, :legal_unit, foreign_key: true
  end
end
