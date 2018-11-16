class CreateCandidateRatingsAgain < ActiveRecord::Migration[5.0]
  def change
    create_table :candidate_ratings do |t|
      t.integer :rating_type
      t.integer :value
      t.string :comment
      t.references :vacancy_stage, foreign_key: true
      t.references :user, foreign_key: true
      t.references :candidate_vacancy, foreign_key: true

      t.timestamps
    end
  end
end
