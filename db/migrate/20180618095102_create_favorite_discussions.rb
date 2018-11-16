class CreateFavoriteDiscussions < ActiveRecord::Migration[5.0]
  def change
    create_table :favorite_discussions do |t|
      t.references :profile, foreign_key: true
      t.references :discussion, foreign_key: true

      t.timestamps
    end
  end
end
