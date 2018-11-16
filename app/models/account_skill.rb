class AccountSkill < ApplicationRecord
  belongs_to :account, touch: true
  belongs_to :skill
  belongs_to :project
  has_many :skill_confirmations, -> { order created_at: :desc }, dependent: :destroy
  accepts_nested_attributes_for :skill, reject_if: :all_blank, allow_destroy: true
end
