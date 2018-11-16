class AddExternalRefsToLegalUnits < ActiveRecord::Migration[5.0]
  def change
    add_column :legal_units, :external_id, :string
    add_column :legal_units, :external_system, :string
  end
end
