module Api::V0::BirthDates
  extend ActiveSupport::Concern

  included do
    private

    def json_collection_inclusion
      @json_collection_inclusion ||= {}
    end

    def json_resource_inclusion
      @json_resource_inclusion ||= {
        methods: %i[departments_chain position_name full_name]
      }
    end

    def chain_collection_inclusion
      @chain_collection_inclusion ||= []
    end

    def chain_resource_inclusion
      @chain_resource_inclusion ||= [
        default_legal_unit_employee: [position: %i[position department]],
        preferred_email: [], account_emails: []
      ]
    end
  end
end
