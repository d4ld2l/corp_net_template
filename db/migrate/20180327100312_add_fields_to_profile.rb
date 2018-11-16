class AddFieldsToProfile < ActiveRecord::Migration[5.0]
  def change
    add_column :profiles, :marital_status, :integer
    add_column :profiles, :kids, :integer, default: 0, null: false
  end
end
