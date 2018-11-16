class Position < ApplicationRecord
  acts_as_tenant :company

  belongs_to :position_group, primary_key: :code, foreign_key: :position_group_code
  belongs_to :legal_unit
  belongs_to :contract_type

  validates :code, :name_ru, presence: true
  validates_uniqueness_of :code, scope: [:legal_unit_id]
end
