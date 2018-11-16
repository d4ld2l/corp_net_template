class PersonalNotificationsWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'high'

  def perform(params)
    account_id = params.delete('account_id')
    action_type = params.delete('action_type')
    issuer_json = params.delete('issuer_json')
    initiator_id = params.delete('initiator_id')
    if account_id.is_a? Array
      account_id.each do |i|
        PersonalNotification.notify_user(i, action_type, issuer_json, initiator_id)
      end
    else
      PersonalNotification.notify_user(account_id, action_type, issuer_json, initiator_id) if account_id.present?
    end
  end
end
