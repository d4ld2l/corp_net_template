class AddServiceToComment < ActiveRecord::Migration[5.2]
  def change
    add_column :comments, :service, :boolean, null: false, default: false
  end
end
