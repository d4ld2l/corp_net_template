# Группы для статусов заявок сервиса
class BidStagesGroup < ApplicationRecord
  has_many :services, dependent: :nullify
  has_many :bid_stages, dependent: :destroy
  has_many :allowed_bid_stages, through: :bid_stages
  enum initial_executor: %i[author matching_user assistant]

  accepts_nested_attributes_for :bid_stages, reject_if: :all_blank, allow_destroy: true

  with_options(on: %i[step_1 create]) do
    validates :name, :code, presence: true
    validates :code, format: { with: /\A[a-zA-Z_\-0-9]+\z/, message: 'должен быть набрано латинскими буквами' }
  end

  with_options(on: %i[step_1 update]) do
    validates :name, :code, presence: true
    validates :code, format: { with: /\A[a-zA-Z_\-0-9]+\z/, message: 'должен быть набрано латинскими буквами' }
  end

  with_options(on: %i[step_2 update]) do
    with_options if: -> { self.bid_stages.any? } do
      validate :must_be_one_initial_stage
      validate :must_be_uniq_stages_codes
    end
  end

  with_options(on: %i[step_3 update]) do
    validate :allowed_bid_stages_valid?
  end

  acts_as_tenant :company

  private

  def must_be_one_initial_stage
    errors.add(:bid_stages_initial, 'должен быть установлен начальный статус') unless bid_stages.map(&:initial).any?
  end

  def must_be_uniq_stages_codes
    errors.add(:bid_stages_codes, 'коды статусов должны быть уникальными') if bid_stages.map(&:code).uniq.size != bid_stages.size
  end

  def allowed_bid_stages_valid?
    allowed_bid_stages.each(&:valid?)
  end
end
