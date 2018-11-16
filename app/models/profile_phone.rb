class ProfilePhone < ApplicationRecord
  belongs_to :profile, inverse_of: :profile_phones
  enum kind: [:personal, :work, :home, :other]

  # validate :only_one_preferable_phone

  def messengers
    string = ''
    string += 'Telegram ' if telegram?
    string += 'Whatsapp ' if whatsapp?
    string += 'Viber  ' if viber?
    string
  end

  private

  def only_one_preferable_phone
    return unless preferable?

    phones = ProfilePhone.where(preferable: true, profile_id: profile_id)
    if persisted?
      phones = phones.where.not(id: id)
    end
    errors.add(:preferable, 'Может быть только один приоритетный вид связи') unless phones.blank?
  end
end
