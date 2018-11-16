class FixTypoInContactsPhones < ActiveRecord::Migration[5.0]
  def change
    rename_column :contact_phones, :vider, :viber
  end
end
