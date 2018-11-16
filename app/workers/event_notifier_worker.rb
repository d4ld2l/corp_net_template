class EventNotifierWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'notifications', retry: true

  def perform(options)
    event = options.delete('event')
    type = options.delete('type')
    participants = options.delete('participants')
    participants.each {|p| EventMailer.send_email(type, p, event).deliver_later}
  end
end
