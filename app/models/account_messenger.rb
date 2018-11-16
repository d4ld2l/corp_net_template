class AccountMessenger < ApplicationRecord
  belongs_to :account, inverse_of: :account_messengers, touch: true
  enum name: %w[Telegram ICQ Hangout Threema Signal Google\ Allo ]

  before_save :remove_blank_phones

  def remove_blank_phones
    phones.reject!(&:blank?)
  end
end
