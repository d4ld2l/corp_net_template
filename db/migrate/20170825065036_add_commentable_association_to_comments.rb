class AddCommentableAssociationToComments < ActiveRecord::Migration[5.0]
  def change
    add_reference :comments, :commentable, polymorphic: true, index: true
    add_column :comments, :parent_comment_id, :integer, index:true
    remove_column :comments, :news_item_id, :integer
  end
end
