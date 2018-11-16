class SurveyResult < ApplicationRecord
  belongs_to :survey, touch: true
  belongs_to :account
  has_many :survey_answers, -> { joins(:question).order('questions.position asc') }, dependent: :destroy
  has_many :questions, through: :survey_answers

  accepts_nested_attributes_for :survey_answers, reject_if: :all_blank, allow_destroy: true

  acts_as_tenant :company
end
