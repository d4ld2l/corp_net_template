module Api::V0::Resources::SurveyResults
  extend ActiveSupport::Concern

  included do

    private

    def chain_resource_inclusion
      @chain_resource_inclusion ||= [
          :survey_answers
      ]
    end

    def json_resource_inclusion
      @json_resource_inclusion ||= {
          include: :survey_answers
      }
    end
  end
end