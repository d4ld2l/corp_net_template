class LegalUnitEmployeeState < ApplicationRecord
  validates_presence_of :state
  has_paper_trail
end
