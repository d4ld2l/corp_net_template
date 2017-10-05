class ProfessionalSpecialization < ApplicationRecord
  belongs_to :professional_area
  has_and_belongs_to_many :resumes, dependent: :nullify
end
