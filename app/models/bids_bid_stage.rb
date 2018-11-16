# Текущий статус заявки
class BidsBidStage < ApplicationRecord
  belongs_to :bid
  belongs_to :bid_stage

  has_paper_trail only: %i[bid_id bid_stage_id]
end
