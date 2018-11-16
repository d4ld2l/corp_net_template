class CreateLikes < ActiveRecord::Migration[5.0]
  def change
    create_table :likes do |t|
      t.references :likable, polymorphic: true, index: true
      t.references :profile, foreign_key: true, index: true

      t.timestamps
    end
  end
end
