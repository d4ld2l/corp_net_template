class SurveyParticipant < ApplicationRecord
  belongs_to :survey, touch: true
  belongs_to :account

  validates_uniqueness_of :account_id, scope: :survey_id
end
