class ContactPhone < ApplicationRecord
  belongs_to :contactable, polymorphic: true

  enum kind: [:personal, :work, :home, :other]

  def messengers
    string = ''
    string += 'Telegram ' if telegram?
    string += 'Whatsapp ' if whatsapp?
    string += 'Viber  ' if viber?
    string
  end
end
