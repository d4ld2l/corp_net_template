class BonusInformationParticipant < ApplicationRecord
  belongs_to :account
  belongs_to :bonus_information
  belongs_to :legal_unit
  belongs_to :bonus_reason
end
