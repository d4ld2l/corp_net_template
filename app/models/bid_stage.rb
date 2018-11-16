# Статусы заявок
class BidStage < ApplicationRecord
  has_many :bids_bid_stages, dependent: :destroy
  has_many :bids, through: :bids_bid_stages
  has_many :allowed_bid_stages, foreign_key: :current_stage_id, dependent: :destroy
  belongs_to :bid_stages_group

  accepts_nested_attributes_for :allowed_bid_stages, reject_if: :all_blank, allow_destroy: true

  scope :as_executor, ->(account_id) { left_joins(bids_bid_stages: :bid).where('bids.manager_id = ?', account_id).distinct }
  scope :as_author, ->(account_id) { left_joins(bids_bid_stages: :bid).where('bids.author_id = ?', account_id).distinct }

  validates :name, :code, presence: true
  validates :code, format: { with: /\A[a-zA-Z_\-0-9]+\z/, message: 'должен быть набрано латинскими буквами' }
  validate :allowed_stages_must_be_uniq

  acts_as_tenant :company

  def get_allowed_stages
    allowed_bid_stages.map { |s| s.next_bid_stage.code }
  end

  def get_allowed_stages_for_api
    allowed_bid_stages.map { |s| { code: s&.next_bid_stage&.code, button_name: s&.name_for_button } }
  end

  def get_allowed_stages_with_id
    allowed_bid_stages.map { |s| [s.next_bid_stage.name, s.next_bid_stage.id] }
  end

  def stage_is_a?(code)
    code.to_sym == code
  end

  def allowed_stages_must_be_uniq
    array = allowed_bid_stages_map_by_keys
    errors.add(:allowed_transition, 'переходы должны быть уникальными') unless array.uniq.size == array.size
  end

  def allowed_bid_stages_map_by_keys
    allowed_bid_stages.map { |stage| [stage.allowed_stage_id, stage.current_stage_id] }
  end
end
