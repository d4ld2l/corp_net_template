class TicketSenderWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'critical', retry: true


  def perform(token, account_id)
    r = Redis.new(url: ENV['REDIS_URL'] + '/0')
    r.set("ws_tickets:#{token}", account_id)
    r.expire("ws_tickets:#{token}", 60)
    r.close
  end
end
