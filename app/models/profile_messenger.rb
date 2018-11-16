class ProfileMessenger < ApplicationRecord
  belongs_to :profile, inverse_of: :profile_messengers
  enum name: %w[Telegram ICQ Hangout Threema Signal Google\ Allo]

  before_save :remove_blank_phones

  def remove_blank_phones
    phones.reject!(&:blank?)
  end
end
