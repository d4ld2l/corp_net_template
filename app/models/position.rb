class Position < ApplicationRecord
  belongs_to :position_group, primary_key: :code, foreign_key: :position_group_code
  belongs_to :legal_unit
  belongs_to :contract_type

  validates :code, :name_ru, :description, presence: true
  validates_uniqueness_of :code, scope: [:legal_unit_id]
end
