class AddAvailableForAllToEvent < ActiveRecord::Migration[5.0]
  def change
    add_column :events, :available_for_all, :boolean, null: false, default: false
  end
end
