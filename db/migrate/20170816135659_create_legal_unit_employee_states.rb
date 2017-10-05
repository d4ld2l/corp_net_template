class CreateLegalUnitEmployeeStates < ActiveRecord::Migration[5.0]
  def change
    create_table :legal_unit_employee_states do |t|
      t.string :state
      t.datetime :changed_at
      t.integer :changed_by
      t.string :comment

      t.timestamps
    end
  end
end
