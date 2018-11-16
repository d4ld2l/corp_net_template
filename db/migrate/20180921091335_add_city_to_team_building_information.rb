class AddCityToTeamBuildingInformation < ActiveRecord::Migration[5.2]
  def change
    add_column :team_building_informations, :city, :string
  end
end
