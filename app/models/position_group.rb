class PositionGroup < ApplicationRecord
  acts_as_tenant :company

  belongs_to :legal_unit
  has_many :positions, foreign_key: :position_group_code, primary_key: :code

  accepts_nested_attributes_for :positions, allow_destroy: true

  validates :code, :name_ru, presence: true
end
