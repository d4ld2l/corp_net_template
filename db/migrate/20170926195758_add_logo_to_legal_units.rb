class AddLogoToLegalUnits < ActiveRecord::Migration[5.0]
  def change
    add_column :legal_units, :logo, :string
  end
end
