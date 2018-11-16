class TeamBuildingInformationLegalUnit < ApplicationRecord
  belongs_to :team_building_information
  belongs_to :legal_unit

  validates_uniqueness_of :legal_unit_id, scope: :team_building_information_id
end
