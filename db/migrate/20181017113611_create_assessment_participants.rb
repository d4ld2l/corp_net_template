class CreateAssessmentParticipants < ActiveRecord::Migration[5.2]
  def change
    create_table :assessment_participants do |t|
      t.belongs_to :account, foreign_key: true
      t.belongs_to :assessment_session, foreign_key: true
      t.integer :kind, default: 0, null: false, index: true

      t.timestamps
    end
  end
end
