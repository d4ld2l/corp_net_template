class ResumeSkill < ApplicationRecord
  belongs_to :resume, touch: true
  belongs_to :skill
  has_many :confirm_skills
end
