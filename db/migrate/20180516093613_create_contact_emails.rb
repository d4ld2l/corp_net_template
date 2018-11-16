class CreateContactEmails < ActiveRecord::Migration[5.0]
  def change
    create_table :contact_emails do |t|
      t.integer :kind, default: 0
      t.references :contactable, polymorphic: true, index: true
      t.string :email
      t.boolean :preferable, default: false

      t.timestamps
    end
  end
end
