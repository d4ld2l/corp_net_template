class CreateTeamBuildingInformations < ActiveRecord::Migration[5.2]
  def change
    create_table :team_building_informations do |t|
      t.references :bid, foreign_key: true
      t.integer :company_id, index: true
      t.integer :project_id
      t.integer :number_of_participants
      t.string :event_format
      t.integer :approx_cost
      t.string :additional_info
      t.datetime :event_date
      t.timestamps
    end
  end
end
