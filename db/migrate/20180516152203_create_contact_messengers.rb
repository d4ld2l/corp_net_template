class CreateContactMessengers < ActiveRecord::Migration[5.0]
  def change
    create_table :contact_messengers do |t|
      t.integer :name
      t.references :contactable, polymorphic: true
      t.json :phones

      t.timestamps
    end
  end
end
