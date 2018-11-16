class CreateSimilarCandidatesPairs < ActiveRecord::Migration[5.0]
  def change
    create_table :similar_candidates_pairs do |t|
      t.integer :first_candidate_id
      t.integer :second_candidate_id
      t.boolean :checked, null: false, default: false

      t.index [:first_candidate_id, :second_candidate_id], unique: true, name: 'similar_candidates_index'

      t.timestamps
    end
    add_foreign_key :similar_candidates_pairs, :candidates, column: :first_candidate_id
    add_foreign_key :similar_candidates_pairs, :candidates, column: :second_candidate_id
  end
end
