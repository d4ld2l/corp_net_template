class LanguageLevel < ApplicationRecord
  has_many :language_skills, dependent: :destroy

  acts_as_tenant :company
end
