class Api::V0::Resources::TemplateStagesController < Api::ResourceController
  before_action :authenticate_account!

  private

  def chain_collection_inclusion
    @chain_collection_inclusion ||= [vacancy_stages: [:vacancy_stage_group]]
  end

  def chain_resource_inclusion
    @chain_resource_inclusion ||= [vacancy_stages: [:vacancy_stage_group]]
  end

  def json_collection_inclusion
    @json_collection_inclusion ||= {
      include: {
        vacancy_stages: {
          include: {
            vacancy_stage_group: {
            }
          }
        }
      }
    }
  end

  def json_resource_inclusion
    @json_resource_inclusion ||= {
      include: {
        vacancy_stages: {
          include: {
            vacancy_stage_group: {
            }
          }
        }
      }
    }
  end

  def permitted_attributes
    [:name, vacancy_stages_attributes: %i[id vacancy_stage_group_id need_notification evaluation_of_candidate type_of_rating _destroy]]
  end
end
