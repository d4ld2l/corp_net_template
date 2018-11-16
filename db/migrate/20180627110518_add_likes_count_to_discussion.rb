class AddLikesCountToDiscussion < ActiveRecord::Migration[5.0]
  def change
    add_column :discussions, :likes_count, :integer
  end
end
