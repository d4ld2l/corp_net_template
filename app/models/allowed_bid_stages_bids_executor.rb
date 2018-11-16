class AllowedBidStagesBidsExecutor < ApplicationRecord
  belongs_to :bids_executor
  belongs_to :allowed_bid_stage
end
