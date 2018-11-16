class AddTaskableToTask < ActiveRecord::Migration[5.2]
  def change
    add_reference :tasks, :taskable, polymorphic: true
  end
end
