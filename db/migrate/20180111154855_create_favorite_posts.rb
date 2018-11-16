class CreateFavoritePosts < ActiveRecord::Migration[5.0]
  def change
    create_table :favorite_posts do |t|
      t.references :post, foreign_key: true
      t.references :profile, foreign_key: true

      t.timestamps
    end
  end
end
