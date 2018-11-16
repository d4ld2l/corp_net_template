class CreateAssessmentSessions < ActiveRecord::Migration[5.2]
  def change
    create_table :assessment_sessions do |t|
      t.string :name
      t.belongs_to :account, foreign_key: true
      t.integer :kind, default: 0, null: false
      t.belongs_to :project_role, foreign_key: true
      t.integer :rating_scale, default: 0, null: false
      t.string :status
      t.text :description
      t.text :final_step_text
      t.string :logo
      t.string :color
      t.integer :created_by

      t.timestamps
    end
    add_index :assessment_sessions, :created_by
  end
end
