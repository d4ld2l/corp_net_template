class BidsExecutor < ApplicationRecord
  belongs_to :account, optional: true
  has_many :allowed_bid_stages_bids_executors, dependent: :nullify
  has_many :allowed_bid_stages, through: :allowed_bid_stages_bids_executors
  has_many :executors_for_bids, class_name: 'AllowedBidStage', foreign_key: :additional_executor_id, dependent: :nullify

  delegate :full_name, to: :account
end
