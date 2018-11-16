class CreateResumeContacts < ActiveRecord::Migration[5.0]
  def change
    create_table :resume_contacts do |t|
      t.references :resume, foreign_key: true
      t.integer :contact_type, default: 0
      t.string :value
      t.boolean :preferred, default: false

      t.timestamps
    end
  end
end
