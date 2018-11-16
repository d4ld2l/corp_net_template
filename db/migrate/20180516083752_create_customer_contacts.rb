class CreateCustomerContacts < ActiveRecord::Migration[5.0]
  def change
    create_table :customer_contacts do |t|
      t.references :customer, index: true
      t.string :name
      t.string :city
      t.string :position
      t.string :description

      t.timestamps
    end
  end
end
