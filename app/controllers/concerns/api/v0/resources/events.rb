module Api::V0::Resources::Events
  extend ActiveSupport::Concern

  included do
    private

    def chain_resource_inclusion
      @chain_resource_inclusion ||= [
        :event_type, :documents, :participants,
        event_participants: [
          participant: [
            default_legal_unit_employee: [position: %i[position department]],
            preferred_email: [], account_emails: []
          ]
        ],
        created_by: [
          default_legal_unit_employee: [position: %i[position department]],
          preferred_email: [], account_emails: []
        ]
      ]
    end

    def chain_collection_inclusion
      @chain_collection_inclusion ||= [
        :event_type, :documents, :participants,
        event_participants: [
          participant: [
            default_legal_unit_employee: [position: %i[position department]],
            preferred_email: [], account_emails: []

          ]
        ],
        created_by: [
          default_legal_unit_employee: [position: %i[position department]],
          preferred_email: [], account_emails: []
        ]
      ]
    end

    def json_collection_inclusion
      @json_collection_inclusion ||= {
        methods: %i[participants_count participants_list created_by],
        include: { event_type: {}, documents: {}, participants: {} }
      }
    end

    def json_resource_inclusion
      @json_resource_inclusion ||= {
        methods: %i[participants_count participants_list created_by],
        include: { event_type: {}, documents: {}, participants: {} }
      }
    end
  end
end
