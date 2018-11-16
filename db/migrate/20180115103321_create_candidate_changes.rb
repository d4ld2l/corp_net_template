class CreateCandidateChanges < ActiveRecord::Migration[5.0]
  def change
    create_table :candidate_changes do |t|
      t.integer :change_type
      t.datetime :timestamp
      t.references :user, foreign_key: true
      t.references :vacancy, foreign_key: true
      t.references :candidate, foreign_key: true
      t.references :change_for, polymorphic: true, index: true

      t.timestamps
    end
  end
end
