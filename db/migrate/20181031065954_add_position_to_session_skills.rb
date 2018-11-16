class AddPositionToSessionSkills < ActiveRecord::Migration[5.2]
  def change
    add_column :assessment_session_skills, :position, :integer, default: 0
  end
end
