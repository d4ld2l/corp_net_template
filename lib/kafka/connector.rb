class Kafka::Connector
  def initialize(topic)
    @topic = topic
    @kafka = Kafka.new(seed_brokers: [ENV['KAFKA_URL']])
  end

  def send(messages, key)
    producer = @kafka.producer
    messages.each do |message|
      producer.produce(message, topic: @topic, key: key)
    end
    producer.deliver_messages
    producer.shutdown
  end
end
