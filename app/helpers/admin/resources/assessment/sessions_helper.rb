module Admin::Resources::Assessment::SessionsHelper
  def full_name_and_email(account)
    "#{account.full_name} (#{account.email})"
  end

  def participants_for_index(session)
    total = session.participants_count
    total += 1 unless session.participants.pluck(:account_id).include?(session.account_id)
    participated = session.evaluations_count
    "#{participated} / #{total}"
  end
end
