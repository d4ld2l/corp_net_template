class ProfileEmail < ApplicationRecord
  belongs_to :profile, inverse_of: :profile_emails
  enum kind: %i[personal work other]

  # validate :only_one_preferable_email

  private

  def only_one_preferable_email
    return unless preferable?

    emails = ProfileEmail.where(preferable: true, profile_id: profile_id)
    if persisted?
      emails = emails.where.not(id: id)
    end
    errors.add(:preferable, 'Может быть только один приоритетный вид связи') unless emails.blank?
  end
end
