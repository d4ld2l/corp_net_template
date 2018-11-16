class AddFieldsToLegalUnits < ActiveRecord::Migration[5.0]
  def change
    add_column :legal_units, :full_name, :string
    add_column :legal_units, :legal_address, :string
    add_column :legal_units, :inn_number, :string
    add_column :legal_units, :kpp_number, :string
    add_column :legal_units, :ogrn_number, :string
    add_column :legal_units, :city, :string
    add_column :legal_units, :general_director, :string
    add_column :legal_units, :administrative_director, :string
    add_column :legal_units, :general_accountant, :string
  end
end
