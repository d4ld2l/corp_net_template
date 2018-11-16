module Api::V0::Resources::LegalUnits
  extend ActiveSupport::Concern

  included do

    private

    def chain_resource_inclusion
      @chain_resource_inclusion ||= [
        :projects,
        :assistant,
        accounts: [
          default_legal_unit_employee: [legal_unit_employee_position: [:position]]
        ],
        legal_unit_employees: [
          account: [
            default_legal_unit_employee: [legal_unit_employee_position: [:position]]
          ],
          position: [:position]
        ]
      ]
    end

    def chain_collection_inclusion
      @chain_collection_inclusion ||= [
        :projects,
        :assistant,
        accounts: [
          default_legal_unit_employee: [legal_unit_employee_position: [:position]]
        ],
        legal_unit_employees: [
          account: [
            default_legal_unit_employee: [legal_unit_employee_position: [:position]]
          ],
          position: [:position]
        ]
      ]
    end

    def json_collection_inclusion
      @json_collection_inclusion ||= {
        include: {
          assistant: {}, accounts: { methods: %i[full_name position_name] },
          legal_unit_employees: {
            include: {
              account: { methods: %i[full_name position_name] },
              position: { methods: [:position_name] }
            },
            projects: {}
          }
        }
      }
    end

    def json_resource_inclusion
      @json_resource_inclusion ||= {
        include: {
          assistant: {}, accounts: { methods: %i[full_name position_name] },
          legal_unit_employees: {
            include: {
              account: { methods: %i[full_name position_name] },
              position: { methods: [:position_name] }
            },
            projects: {}
          }
        }
      }
    end
  end
end