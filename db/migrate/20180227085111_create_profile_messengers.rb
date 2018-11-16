class CreateProfileMessengers < ActiveRecord::Migration[5.0]
  def change
    create_table :profile_messengers do |t|
      t.integer :name
      t.references :profile, foreign_key: true, index: true
      t.json :phones, default: []

      t.timestamps
    end
  end
end
