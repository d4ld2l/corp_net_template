class CreateDiscussions < ActiveRecord::Migration[5.0]
  def change
    create_table :discussions do |t|
      t.string :name, null: false, default: ''
      t.string :body, null: false, default: ''
      t.integer :author_id
      t.integer :state, null: false, default: 0
      t.integer :comments_count
      t.boolean :available_to_all, null: false, default: false
      t.references :discussable, polymorphic: true
      t.datetime :last_comment_at

      t.timestamps
    end
    add_index :discussions, :author_id
  end
end
