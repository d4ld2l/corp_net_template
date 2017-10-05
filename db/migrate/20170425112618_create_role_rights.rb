class CreateRoleRights < ActiveRecord::Migration[5.0]
  def change
    create_table :role_rights do |t|
      t.references :role, foreign_key: true
      t.string :module_code, limit: 100
      t.string :object_code, limit: 100
      t.string :group_code, limit: 20
      t.integer :rights

      t.timestamps
    end
  end
end
