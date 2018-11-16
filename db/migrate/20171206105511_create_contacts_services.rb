class CreateContactsServices < ActiveRecord::Migration[5.0]
  def change
    create_table :contacts_services do |t|
      t.belongs_to :service, foreign_key: true
      t.belongs_to :contact, foreign_key: { to_table: :users }
      t.timestamps
    end

    remove_column :services, :contact_id, :integer
  end
end
