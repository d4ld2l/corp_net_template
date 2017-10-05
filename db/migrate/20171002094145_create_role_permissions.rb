class CreateRolePermissions < ActiveRecord::Migration[5.0]
  def change
    create_table :role_permissions do |t|
      t.belongs_to :role, foreign_key: true
      t.belongs_to :permission, foreign_key: true

      t.timestamps
    end
  end
end
