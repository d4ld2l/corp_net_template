class CreateCandidateRatings < ActiveRecord::Migration[5.0]
  def change
    create_table :candidate_ratings do |t|
      t.integer :rating_type
      t.integer :value
      t.string :comment
      t.references :user, foreign_key: true
      t.references :candidate_vacancy_stage, foreign_key: true

      t.timestamps
    end
  end
end
