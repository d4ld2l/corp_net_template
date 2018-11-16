class CreateProfileReadingEntities < ActiveRecord::Migration[5.0]
  def change
    create_table :profile_reading_entities do |t|
      t.references :profile, foreign_key: true
      t.references :readable, polymorphic: true
      t.datetime :last_read_at

      t.timestamps
    end
  end
end
