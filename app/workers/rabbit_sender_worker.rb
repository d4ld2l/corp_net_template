class RabbitSenderWorker
  include Sidekiq::Worker
  require 'bunny'
  sidekiq_options queue: 'critical', retry: 5

  def perform(receiver_ids, meta, data)
    return if receiver_ids.blank?
    connection = Bunny.new(host: ENV['RABBIT_HOST'],
                           port: ENV['RABBIT_PORT'],
                           user: ENV['RABBIT_USERNAME'],
                           pass: ENV['RABBIT_PASSWORD'])
    connection.start

    channel = connection.create_channel
    exchange = channel.fanout('discussions', durable: true)

    receiver_ids.each do |rid|
      message = { meta: meta.to_json, data: data.to_json, receiver_id: rid }
      exchange.publish(message.to_json, persistent: true)
    end

    connection.close
  end
end
