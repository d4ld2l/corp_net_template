class ContactMessenger < ApplicationRecord
  belongs_to :contactable, polymorphic: true

  enum name: %w[Telegram ICQ Hangout Threema Signal Google\ Allo ]

  attr_accessor :phones_string

  before_save :remove_blank_phones

  def remove_blank_phones
    phones.reject!(&:blank?)
  end

  def phones_string
    phones&.join(', ')
  end

  def phones_string=(arr)
    self.phones = arr&.split(', ')
  end
end
