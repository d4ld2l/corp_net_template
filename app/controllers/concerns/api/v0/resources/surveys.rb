module Api::V0::Resources::Surveys
  extend ActiveSupport::Concern

  included do
    private

    def chain_resource_inclusion
      @chain_resource_inclusion ||= %i[
        survey_results documents
        editor
        creator
        publisher
        unpublisher
      ]
    end

    def chain_collection_inclusion
      @chain_collection_inclusion ||= %i[
        survey_results documents
        editor
        creator
        publisher
        unpublisher
      ]
    end

    def json_collection_inclusion
      @json_collection_inclusion ||= {
        include: { documents: {},
                   editor: {
                     only: [:id],
                     methods: [:full_name]
                   },
                   creator: {
                     only: [:id],
                     methods: [:full_name]
                   },
                   unpublisher: {
                     only: [:id],
                     methods: [:full_name]
                   },
                   publisher: {
                     only: [:id],
                     methods: [:full_name]
                   } },
        methods: %i[passed created_by_me]
      }
    end

    def json_resource_inclusion
      @json_resource_inclusion ||= {
        include: { documents: {},
                   editor: {},
                   creator: {},
                   unpublisher: {},
                   publisher: {},
                   questions: { include:
                                  { offered_variants: { methods: %i[users_count users_percentage] } },
                                methods: %i[own_answer_count own_answer_percentage] } },
        methods: %i[participants_list passed created_by_me]
      }
    end
  end
end
