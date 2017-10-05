class CreateAdditionalContacts < ActiveRecord::Migration[5.0]
  def change
    create_table :additional_contacts do |t|
      t.integer :type
      t.string :link

      t.timestamps
    end
    add_reference :additional_contacts, :resume, index: true
  end
end
