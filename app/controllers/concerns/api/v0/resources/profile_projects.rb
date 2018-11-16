module Api::V0::Resources::ProfileProjects
  extend ActiveSupport::Concern

  included do

    private

    def chain_resource_inclusion
      @chain_resource_inclusion ||= [
          profile:[:profile_phones, :profile_emails, :profile_messengers,
                   :preferred_email, :preferred_phone, :user,
                   default_legal_unit_employee: [legal_unit_employee_position: [:position, :department]],
                   skills:[
                       skill_confirmations:[
                           profile:[
                               default_legal_unit_employee: [legal_unit_employee_position: [:position, :department]]
                           ]
                       ]
                   ]
          ],
          project_work_periods:[]
      ]
    end

    def chain_collection_inclusion
      @chain_collection_inclusion ||= [
          profile:[:profile_phones, :profile_emails, :profile_messengers, :preferred_email, :preferred_phone, :default_legal_unit_employee, :user],
          project_work_periods:[]
      ]
    end

    def json_collection_inclusion
      @json_collection_inclusion ||= {
          include: { profile:{methods:[:full_name, :position_name, :preferred_phone, :preferred_email]}, project_work_periods:{} }
      }
    end

    def json_resource_inclusion
      @json_resource_inclusion ||= {
          include: { profile:{methods:[:full_name, :position_name, :preferred_phone, :preferred_email], include:{
              skills: {methods: [:skill_confirmations_count], include: [
                  skill_confirmations: {include: [profile: {methods: [:full_name, :position_name, :departments_chain]}]}]},
          }}, project_work_periods:{} }
      }
    end
  end
end