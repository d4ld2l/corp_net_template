class ProfessionalSpecializationsResume < ApplicationRecord
	belongs_to :professional_specialization
	belongs_to :resume, touch: true
end
