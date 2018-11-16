class MakePriorityNullableInTasks < ActiveRecord::Migration[5.0]
  def change
    change_column :tasks, :priority, :integer, null: true, default: nil
  end
end
