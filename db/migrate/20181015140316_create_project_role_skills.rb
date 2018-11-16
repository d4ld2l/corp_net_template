class CreateProjectRoleSkills < ActiveRecord::Migration[5.2]
  def change
    create_table :project_role_skills do |t|
      t.belongs_to :skill, foreign_key: true
      t.belongs_to :project_role, foreign_key: true

      t.timestamps
    end
    add_reference :project_role_skills, :company, index: true
  end
end
