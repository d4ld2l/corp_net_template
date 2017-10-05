class AddChargeCodeToProjects < ActiveRecord::Migration[5.0]
  def change
    add_column :projects, :charge_code, :string
  end
end
