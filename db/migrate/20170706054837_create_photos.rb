class CreatePhotos < ActiveRecord::Migration[5.0]
  def change
    create_table :photos do |t|
      t.string :name
      t.string :file
      t.integer :photo_attachable_id
      t.string :photo_attachable_type

      t.timestamps
    end
  end
end
