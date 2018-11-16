class DeletePasswordFromProfile < ActiveRecord::Migration[5.0]
  def change
    remove_column :profiles, :password, :string
  end
end
