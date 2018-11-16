class CreateAdminSettings < ActiveRecord::Migration[5.0]
  def change
    create_table :admin_settings do |t|
      t.string :name, null: false, default: ''
      t.string :label, null: false, default: ''
      t.string :value, null: false, default: ''
      t.integer :kind, null: false

      t.timestamps
    end
  end
end
