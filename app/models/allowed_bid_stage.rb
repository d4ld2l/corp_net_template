# Статусы разрешенный для перехода
class AllowedBidStage < ApplicationRecord
  belongs_to :current_bid_stage, class_name: 'BidStage', foreign_key: :current_stage_id
  belongs_to :next_bid_stage, class_name: 'BidStage', foreign_key: :allowed_stage_id
  belongs_to :additional_executor, class_name: 'BidsExecutor', foreign_key: :additional_executor_id, optional: true
  has_many :allowed_bid_stages_bids_executors, dependent: :destroy
  has_many :bids_executors, through: :allowed_bid_stages_bids_executors
  enum executor: %i[author matching_user assistant]

  validates :allowed_stage_id, :name_for_button, presence: true
  validates_uniqueness_of :allowed_stage_id, scope: :current_stage_id
  validate :allowed_and_current_must_not_eql
  validate :must_be_one_checkbox
  validate :check_notification

  def allowed_and_current_must_not_eql
    if current_stage_id == allowed_stage_id
      errors.add(:allowed_eql_current, "нельзя перейти из #{current_bid_stage.name}(#{current_bid_stage.code}) в #{next_bid_stage.name}(#{next_bid_stage.code})")
    end
  end

  def check_notification
    if notification? && (notifiable&.reject{|x| x.empty?}.blank? && bids_executors.blank?)
      errors.add(:notification, 'Должен быть выбран хотя бы один участник для уведомления')
    end
  end

  def must_be_one_checkbox
    if executor.present? == additional_executor_id.present?
      errors.add(:must_be_one_checkbox, 'Исполнитель может быть только один')
    end
  end
end
