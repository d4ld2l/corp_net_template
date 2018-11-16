class RenameUserToCommenterInCandidateRatings < ActiveRecord::Migration[5.0]
  def change
    remove_column :candidate_ratings, :user_id, :integer
    add_column :candidate_ratings, :commenter_id, :integer, foreign_key: true
  end
end
