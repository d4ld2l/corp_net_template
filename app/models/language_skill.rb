class LanguageSkill < ApplicationRecord
  belongs_to :language
  belongs_to :language_level
  belongs_to :resume
end
