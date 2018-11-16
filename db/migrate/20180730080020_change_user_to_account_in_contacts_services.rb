class ChangeUserToAccountInContactsServices < ActiveRecord::Migration[5.2]
  def change
    remove_foreign_key :contacts_services, column: :contact_id
  end
end
