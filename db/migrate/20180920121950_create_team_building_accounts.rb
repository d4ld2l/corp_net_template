class CreateTeamBuildingAccounts < ActiveRecord::Migration[5.2]
  def change
    create_table :team_building_information_accounts do |t|
      t.references :account, foreign_key: true
      t.integer :company_id, index: true
      t.references :team_building_information, foreign_key: true, index: {name: "index_team_building_info_accounts_tb_id"}
      t.timestamps
    end
  end
end
