class CreateAccountRoles < ActiveRecord::Migration[5.2]
  def change
    create_table :account_roles do |t|
      t.references :role, foreign_key: true
      t.references :account, foreign_key: true

      t.timestamps
    end
  end
end
