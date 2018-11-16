class AddExternalRefsToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :external_id, :string
    add_column :users, :external_system, :string
  end
end
