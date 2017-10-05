class CommunitiesUser < ApplicationRecord
  include AASM
  include ChangeAasmState

  belongs_to :user
  belongs_to :community

  scope :users_in_status, ->(status) { where(status: status).map(&:user) }
  scope :users_in_status_count, ->(status) { where(status: status).distinct.count }

  aasm column: :status do
    state :accepted, initial: true
    state :expected, :rejected, :excluded, :deleted

    event :to_accepted do
      transitions from: [:rejected, :expected, :excluded], to: :accepted
    end

    event :to_expected do
      transitions from: :accepted, to: :expected
    end

    event :to_excluded do
      transitions from: [:accepted, :expected], to: :excluded
    end

    event :to_rejected do
      transitions from: :expected, to: :rejected
    end
  end
end
