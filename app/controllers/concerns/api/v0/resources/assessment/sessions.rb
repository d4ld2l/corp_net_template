module Api::V0::Resources::Assessment::Sessions
  extend ActiveSupport::Concern

  included do

    private

    def chain_resource_inclusion
      @chain_resource_inclusion ||= [
          skills: [ :indicators ]
      ]
    end

    def chain_collection_inclusion
      @chain_collection_inclusion ||= []
    end

    def json_resource_inclusion
      @json_resource_inclusion ||= {
          only: %i[ id name kind project_role_id
                    rating_scale status due_date description final_step_text
                    logo color skills_count updated_at
                    obvious_fortes hidden_fortes growth_direction blind_spots conclusion ],
          methods: %i[ status_name ],
          include: {
              skills:{
                  only: %i[ id name description ],
                  include:{
                      indicators:{
                          only: %i[ id name ]
                      }
                  }
              },
              account:{
                  only: %i[ id ],
                  methods: %i[ full_name ]
              }
          }
      }
    end

    def json_collection_inclusion
      @json_collection_inclusion ||= {
          only: %i[ id name kind logo updated_at skills_count due_date ],
          methods: %i[ status_name ],
          include: {
              account: {
                  only: %i[ id ],
                  methods: %i[ full_name ]
              }
          }
      }
    end

  end
end