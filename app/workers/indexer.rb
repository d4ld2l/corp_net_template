class Indexer
  include Sidekiq::Worker
  sidekiq_options queue: 'elasticsearch-social'

  LOGGER = Sidekiq.logger.level == Logger::DEBUG ? Sidekiq.logger : nil

  def perform(params)
    operation = params.delete('operation')
    klass = params.delete('klass')
    record_id = params.delete('record_id')
    logger.debug [operation, "Class: #{klass} ID: #{record_id}"]
    record = klass.constantize.where(id: record_id)&.first
    if record
      case operation.to_s
      when /index/
        record.__elasticsearch__.index_document
      when /delete/
        record.__elasticsearch__.delete_document
      else
        raise ArgumentError, "Unknown operation '#{operation}'"
      end
    else
      logger.debug ["record not found"]
    end
  end
end