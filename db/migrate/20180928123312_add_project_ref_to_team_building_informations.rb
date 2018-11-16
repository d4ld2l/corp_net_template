class AddProjectRefToTeamBuildingInformations < ActiveRecord::Migration[5.2]
  def change
    remove_column :team_building_informations, :project_id
    add_reference :team_building_informations, :project, foreign_key: true
  end
end
