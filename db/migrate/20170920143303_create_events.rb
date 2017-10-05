class CreateEvents < ActiveRecord::Migration[5.0]
  def change
    create_table :events do |t|
      t.string :name
      t.integer :created_by, foreign_key: true
      t.datetime :starts_at
      t.datetime :ends_at
      t.text :description
      t.references :event_type, foreign_key: true

      t.timestamps
    end
  end
end
