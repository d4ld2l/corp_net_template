class Rabbit::Connector
  require 'bunny'

  def initialize(topic)
    @topic = topic
    @rabbit = Bunny.new(host: ENV['RABBIT_HOST'],
                           port: ENV['RABBIT_PORT'],
                           user: ENV['RABBIT_USERNAME'],
                           pass: ENV['RABBIT_PASSWORD'])
    @rabbit.start
  end

  def send(messages, key)
    channel = @rabbit.create_channel
    queue = channel.queue(@topic)
    messages.each do |message|
      channel.default_exchange.publish(message, routing_key: queue.name)
    end
  end
end
