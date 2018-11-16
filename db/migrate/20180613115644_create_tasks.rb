class CreateTasks < ActiveRecord::Migration[5.0]
  def change
    create_table :tasks do |t|
      t.string :title, null: false, default: ''
      t.text :description, null: false, default: ''
      t.integer :priority, null: false, default: 1
      t.boolean :displayed_in_calendar, null: false, default: false
      t.boolean :done, null: false, default: false
      t.integer :parent_id
      t.datetime :executed_at
      t.datetime :ends_at
      t.integer :executor_id
      t.integer :author_id

      t.timestamps
    end

    add_index :tasks, :parent_id
    add_index :tasks, :executor_id
    add_index :tasks, :author_id
  end
end
