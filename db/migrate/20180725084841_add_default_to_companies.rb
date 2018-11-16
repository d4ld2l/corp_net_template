class AddDefaultToCompanies < ActiveRecord::Migration[5.0]
  def change
    add_column :companies, :default, :boolean, default: false
  end
end
