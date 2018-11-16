class DropCandidateRatings < ActiveRecord::Migration[5.0]
  def change
    drop_table :candidate_ratings
  end
end
