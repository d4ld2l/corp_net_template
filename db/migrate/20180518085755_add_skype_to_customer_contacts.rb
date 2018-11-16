class AddSkypeToCustomerContacts < ActiveRecord::Migration[5.0]
  def change
    add_column :customer_contacts, :skype, :string
  end
end
