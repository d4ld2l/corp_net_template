class ChangeUserToAccountInPosts < ActiveRecord::Migration[5.2]
  def change
    remove_foreign_key :posts, column: :author_id
    remove_foreign_key :posts, column: :deleted_by_id
  end
end
