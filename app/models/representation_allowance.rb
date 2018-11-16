# Представительские расходы
class RepresentationAllowance < ApplicationRecord
  belongs_to :bid
  has_one :information_about_participant, dependent: :destroy
  has_one :meeting_information, dependent: :destroy
  has_one :bid_stage, through: :bid
  has_many :participants, through: :information_about_participants

  accepts_nested_attributes_for :information_about_participant
  accepts_nested_attributes_for :meeting_information

  def revision_required?
    self && bid_stage&.code == 'revision_required'
  end
end
