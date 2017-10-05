class CreateLegalUnitEmployeePositions < ActiveRecord::Migration[5.0]
  def change
    create_table :legal_unit_employee_positions do |t|
      t.string :department_code
      t.string :position_code
      t.date :order_date
      t.string :order_number
      t.string :order_author
      t.references :legal_unit_employee, foreign_key: true
      t.integer :transfer_type

      t.timestamps
    end
  end
end
