module Api::V0::Resources::ServiceGroups
  extend ActiveSupport::Concern

  included do
    private

    def chain_collection_inclusion
      @chain_collection_inclusion ||= [:services]
    end

    def json_collection_inclusion
      @json_collection_inclusion ||= {
        only: [:id, :name],
        include: {
          services: {
            only: [:id, :name, :state, :created_at, :published_at]
          }
        }
      }
    end
  end
end
