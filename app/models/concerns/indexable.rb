module Indexable
  extend ActiveSupport::Concern
  included do
    after_create_commit { Indexer.perform_async(parameters_json('index')) }
    after_update_commit { Indexer.perform_async(parameters_json('index')) }
    after_destroy_commit { Indexer.perform_async(parameters_json('delete')) }

    def self.reindex!
      __elasticsearch__.delete_index! if __elasticsearch__.client.indices.exists?(index: index_name)
      __elasticsearch__.create_index!
      import(force: true)
    end

    def parameters_json(operation)
      @parameters_json ||= {
        operation: operation,
        klass: self.class.name,
        record_id: id
      }
    end
  end
end