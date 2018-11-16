# Транзакция - любая операция по начислению/снятию виртуальных денег пользователю
class Transaction < ApplicationRecord
  # purchase - покупка
  # refill - попролнение
  # penalty - штраф
  enum kind: %i[purchase refill penalty]

  belongs_to :account_achievement
  has_one :achievement, through: :account_achievement
  belongs_to :recipient, class_name: 'Account', optional: false

  after_create :perform
  before_destroy :rollback

  validates :value, numericality: { greater_than_or_equal_to: 0 }

  def perform
    update_balance(1)
  end

  def rollback
    update_balance(-1)
  end

  def sign
    kind.to_sym == :refill ? 1 : -1
  end

  def value_with_sign
    value * sign
  end

  private

  def update_balance(multiplier = 1)
    val = value * multiplier * sign
    recipient.balance += val
    recipient.balance = 0 if recipient.balance.negative?
    recipient.save(validate: false)
  end
end
