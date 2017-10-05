class CreateResumeRecommendations < ActiveRecord::Migration[5.0]
  def change
    create_table :resume_recommendations do |t|
      t.belongs_to :resume, foreign_key: true
      t.string :recommender_name
      t.string :company_and_position
      t.string :phone
      t.string :email

      t.timestamps
    end
  end
end
