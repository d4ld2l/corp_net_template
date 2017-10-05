class AddFieldsToLegalUnitEmployees < ActiveRecord::Migration[5.0]
  def change
    remove_column :legal_unit_employees, :wage, :integer
    add_column :legal_unit_employees, :wage, :float
    add_column :legal_unit_employees, :wage_rate, :float
    add_column :legal_unit_employees, :pay, :float
    add_column :legal_unit_employees, :extrapay, :float
    add_column :legal_unit_employees, :contract_end_at, :date
    add_column :legal_unit_employees, :contract_type_id, :integer
    add_column :legal_unit_employees, :contract_id, :string
    add_column :legal_unit_employees, :probation_period, :string
    add_column :legal_unit_employees, :starts_work_at, :date
  end
end
