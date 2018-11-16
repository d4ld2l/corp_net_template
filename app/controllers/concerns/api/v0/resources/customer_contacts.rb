module Api::V0::Resources::CustomerContacts
  extend ActiveSupport::Concern

  included do

    private

    def chain_resource_inclusion
      @chain_resource_inclusion ||= [
        :contact_messengers, :contact_phones, :contact_emails,
        comments: [
          account: [
            default_legal_unit_employee: [legal_unit_employee_position: %i[position department]]
          ]
        ]
      ]
    end

    def chain_collection_inclusion
      @chain_collection_inclusion ||= [
        :contact_messengers, :contact_phones, :contact_emails,
        comments: [
          account: [
            default_legal_unit_employee: [legal_unit_employee_position: %i[position department]]
          ]
        ]
      ]
    end

    def json_collection_inclusion
      @json_collection_inclusion ||= {
        include: { contact_emails: { except: %i[contactable_type contactable_id] },
                   contact_phones: { except: %i[contactable_type contactable_id] },
                   contact_messengers: { except: %i[contactable_type contactable_id] },
                   comments: { include: { account: { only: %i[photo id], methods: %i[full_name position_name] } } }
        }
      }
    end

    def json_resource_inclusion
      @json_resource_inclusion ||= {
        include: { contact_emails: { except: %i[contactable_type contactable_id] },
                   contact_phones: { except: %i[contactable_type contactable_id] },
                   contact_messengers: { except: %i[contactable_type contactable_id] },
                   comments: { include: { account: { only: %i[photo id], methods: %i[full_name position_name] } } }
        }
      }
    end
  end
end