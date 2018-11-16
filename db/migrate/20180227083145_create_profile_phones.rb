class CreateProfilePhones < ActiveRecord::Migration[5.0]
  def change
    create_table :profile_phones do |t|
      t.integer :kind
      t.string :number
      t.boolean :preferable, default: false
      t.boolean :whatsapp, default: false
      t.boolean :telegram, default: false
      t.boolean :viber, default: false
      t.references :profile, foreign_key: true, index: true

      t.timestamps
    end
  end
end
