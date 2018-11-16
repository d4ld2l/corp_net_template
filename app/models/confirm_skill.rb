class ConfirmSkill < ApplicationRecord
  belongs_to :account
  has_one :resume_skill
end
