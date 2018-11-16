class LanguageSkill < ApplicationRecord
  belongs_to :language
  belongs_to :language_level
  belongs_to :resume, touch: true

  accepts_nested_attributes_for :language, reject_if: :all_blank, allow_destroy: true

  def language_name
    language.name
  end
end
