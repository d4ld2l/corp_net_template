class CreateProfileEmails < ActiveRecord::Migration[5.0]
  def change
    create_table :profile_emails do |t|
      t.string :kind
      t.string :email
      t.boolean :preferable, default: false
      t.references :profile, foreign_key: true, index: true

      t.timestamps
    end
  end
end
