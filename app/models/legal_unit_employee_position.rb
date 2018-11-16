class LegalUnitEmployeePosition < ApplicationRecord
  belongs_to :legal_unit_employee
  belongs_to :department, primary_key: :code, foreign_key: :department_code, required: false
  belongs_to :position, primary_key: :code, foreign_key: :position_code

  validates :department_code, :position_code, presence: true

  def position_name
    position&.name_ru
  end

  has_paper_trail
end
