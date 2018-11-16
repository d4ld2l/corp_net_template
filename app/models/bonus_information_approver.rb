class BonusInformationApprover < ApplicationRecord
  belongs_to :account
  belongs_to :bonus_information
end
