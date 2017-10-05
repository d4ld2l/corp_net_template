class CreateRoleFunctions < ActiveRecord::Migration[5.0]
  def change
    create_table :role_functions do |t|
      t.references :role, foreign_key: true
      t.string :module_code, limit: 100
      t.string :function_code

      t.timestamps
    end
  end
end
