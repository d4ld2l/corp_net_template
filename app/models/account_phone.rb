class AccountPhone < ApplicationRecord
  belongs_to :account, inverse_of: :account_phones, touch: true
  enum kind: %i[personal work home other]

  # validate :only_one_preferable_phone

  def messengers
    string = ''
    string += 'Telegram ' if telegram?
    string += 'Whatsapp ' if whatsapp?
    string += 'Viber  ' if viber?
    string
  end
end
