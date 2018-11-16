class CreateTeamBuildingLegalUnits < ActiveRecord::Migration[5.2]
  def change
    create_table :team_building_information_legal_units do |t|
      t.references :legal_unit, foreign_key: true
      t.references :team_building_information, foreign_key: true, index: {name: "index_team_building_lu_tb_id"}
      t.integer :company_id, index: true

      t.timestamps
    end
  end
end
