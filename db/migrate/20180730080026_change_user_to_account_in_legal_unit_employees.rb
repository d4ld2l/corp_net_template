class ChangeUserToAccountInLegalUnitEmployees < ActiveRecord::Migration[5.2]
  def change
    remove_foreign_key :legal_unit_employees, column: :profile_id
    remove_foreign_key :legal_unit_employees, column: :manager_id
    rename_column :legal_unit_employees, :profile_id, :account_id
  end
end
