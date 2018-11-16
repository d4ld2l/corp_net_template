class AddCountersToTasks < ActiveRecord::Migration[5.2]
  def change
    add_column :tasks, :total_subtasks_count, :integer, null: false, default: 0
    add_column :tasks, :executed_subtasks_count, :integer, null: false, default: 0
  end
end
