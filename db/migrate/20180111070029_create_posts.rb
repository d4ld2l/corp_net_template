class CreatePosts < ActiveRecord::Migration[5.0]
  def change
    create_table :posts do |t|
      t.references :author, index: true
      t.references :community, index: true
      t.string :name
      t.string :body
      t.boolean :allow_commenting, default: true
      t.datetime :edited_at
      t.datetime :deleted_at
      t.references :deleted_by, index: true

      t.timestamps
    end
    add_foreign_key :posts, :profiles, column: :author_id
    add_foreign_key :posts, :profiles, column: :deleted_by_id
  end
end
