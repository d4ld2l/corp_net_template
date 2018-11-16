class EducationLevel < ApplicationRecord
  has_many :resume_educations

  acts_as_tenant :company
end
