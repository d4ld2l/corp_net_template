class ProfessionalArea < ApplicationRecord
  has_many :professional_specializations, dependent: :destroy

  accepts_nested_attributes_for :professional_specializations, reject_if: :all_blank, allow_destroy: true

  acts_as_tenant :company
end
