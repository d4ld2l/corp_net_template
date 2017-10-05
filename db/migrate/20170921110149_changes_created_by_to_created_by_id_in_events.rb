class ChangesCreatedByToCreatedByIdInEvents < ActiveRecord::Migration[5.0]
  def change
    remove_column :events, :created_by, :integer
    add_column :events, :created_by_id, :integer, index: true
  end
end
