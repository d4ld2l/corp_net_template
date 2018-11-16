class ResumeEducation < ApplicationRecord
  belongs_to :resume, touch: true
  belongs_to :education_level

  def education_level_name
    education_level&.name
  end
end
