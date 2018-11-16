module Api::V0::Resources::Services
  extend ActiveSupport::Concern

  included do

    private

    def chain_resource_inclusion
      @chain_resource_inclusion ||= [
        :documents, :notifications,
        contacts: [
          :preferred_email, :account_emails, :preferred_phone, :account_phones,
          default_legal_unit_employee: [
            legal_unit_employee_position: [:position]
          ]
        ]
      ]
    end

    def json_resource_inclusion
      @json_resource_inclusion ||= {
        only: %i[
          id name state description
          is_provided_them order_service
          results term_for_ranting restrictions
          is_bid_required process_description
          supporting_documents
        ],
        include: {
          contacts: {
            only: %i[photo id],
            methods: %i[full_name position_name skype email_address phone telegram]
          },
          documents: {
            only: %i[name],
            methods: %i[url]
          },
          notifications: {
            only: %i[id body],
            methods: [:show_notification]
          }
        }
      }
    end
  end
end
