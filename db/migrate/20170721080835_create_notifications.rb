class CreateNotifications < ActiveRecord::Migration[5.0]
  def change
    create_table :notifications do |t|
      t.references :notice, polymorphic: true, index: true
      t.string :body, limit: 256
      t.boolean :dispatch
      t.belongs_to :user, foreign_key: true

      t.timestamps
    end
  end
end
