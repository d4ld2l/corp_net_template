class BonusInformation < ApplicationRecord
  belongs_to :bid
  belongs_to :bonus_reason

  has_many :bonus_information_approvers, dependent: :destroy
  has_many :bonus_information_participants, dependent: :destroy

  accepts_nested_attributes_for :bonus_information_participants, reject_if: :all_blank
  accepts_nested_attributes_for :bonus_information_approvers, reject_if: :all_blank
end
