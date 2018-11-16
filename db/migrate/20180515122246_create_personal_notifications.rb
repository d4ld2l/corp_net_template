class CreatePersonalNotifications < ActiveRecord::Migration[5.0]
  def change
    create_table :personal_notifications do |t|
      t.references :profile, foreign_key: true, index: true
      t.string :title, null: false, default: ''
      t.string :icon
      t.boolean :read, null: false, default: false
      t.text :body, null: false, default: ''
      t.integer :group_type, null: false, default: 0
      t.integer :module_type, null: false, default: 0
      t.json :issuer, null: false, default: []

      t.timestamps
    end
  end
end
