class CreateLegalUnitEmployees < ActiveRecord::Migration[5.0]
  def change
    create_table :legal_unit_employees do |t|
      t.references :profile, foreign_key: true
      t.references :legal_unit, foreign_key: true
      t.boolean :default
      t.string :employee_number
      t.string :employee_uid
      t.string :individual_employee_uid
      t.integer :manager, foreign_key: true
      t.string :email_corporate
      t.string :email_work
      t.string :phone_corporate
      t.string :phone_work
      t.string :office
      t.date :hired_at
      t.integer :wage
      t.references :legal_unit_employee_state, foreign_key: true

      t.timestamps
    end
  end
end
