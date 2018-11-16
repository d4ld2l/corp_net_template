class SurveyAnswer < ApplicationRecord
  belongs_to :survey_result
  belongs_to :question
  has_many :offered_variants, through: :question
  has_one :account, through: :survey_result

end
