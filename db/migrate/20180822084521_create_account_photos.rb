class CreateAccountPhotos < ActiveRecord::Migration[5.2]
  def change
    create_table :account_photos do |t|
      t.string :photo
      t.references :account, foreign_key: true
      t.datetime :archived_at
      t.timestamps
    end
  end
end
