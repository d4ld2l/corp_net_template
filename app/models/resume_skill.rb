class ResumeSkill < ApplicationRecord
	belongs_to :resume
	belongs_to :skill
	has_many :confirm_skills
end
