module Api::V0::Resources::AccountProjects
  extend ActiveSupport::Concern

  included do

    private

    def chain_resource_inclusion
      @chain_resource_inclusion ||= [
        account: [:account_phones, :account_emails, :account_messengers,
                  :preferred_email, :preferred_phone,
                  default_legal_unit_employee: [legal_unit_employee_position: [:position, :department]],
                  account_skills: [
                      skill:[],
                      skill_confirmations: [
                        account: [
                          default_legal_unit_employee: [legal_unit_employee_position: [:position, :department]]
                        ]
                      ]
                  ]
        ],
        project_work_periods: []
      ]
    end

    def chain_collection_inclusion
      @chain_collection_inclusion ||= [
        account: [:account_phones, :account_emails, :account_messengers, :preferred_email, :preferred_phone, :default_legal_unit_employee],
        project_work_periods: []
      ]
    end

    def json_collection_inclusion
      @json_collection_inclusion ||= {
        include: { account: { methods: [:full_name, :position_name, :preferred_phone, :preferred_email] }, project_work_periods: {} }
      }
    end

    def json_resource_inclusion
      @json_resource_inclusion ||= {
          include: {account: {
              methods: [:full_name, :position_name, :preferred_phone, :preferred_email],
              include: {
                  account_skills: {
                      include: {
                          skill: {
                              only: [:id, :name]
                          },
                          skill_confirmations: {
                              only: %i[id],
                              include: {
                                  account: {
                                      only: %i[id photo],
                                      methods: %i[position_name full_name]
                                  }
                              }
                          }
                      }
                  }
              }}, project_work_periods: {}}
      }
    end
  end
end