class TeamBuildingInformation < ApplicationRecord

  belongs_to :bid
  belongs_to :project

  has_many :team_building_information_accounts, dependent: :destroy
  has_many :accounts, through: :team_building_information_accounts
  accepts_nested_attributes_for :team_building_information_accounts, allow_destroy: true

  has_many :team_building_information_legal_units, dependent: :destroy
  has_many :legal_units, through: :team_building_information_legal_units
  accepts_nested_attributes_for :team_building_information_legal_units, allow_destroy: true


end
