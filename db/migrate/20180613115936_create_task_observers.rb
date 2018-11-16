class CreateTaskObservers < ActiveRecord::Migration[5.0]
  def change
    create_table :task_observers do |t|
      t.references :task, foreign_key: true
      t.references :profile, foreign_key: true

      t.timestamps
    end
  end
end
