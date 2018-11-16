module Api::V0::Resources::Assessment
  class EvaluationsController < Api::ResourceController
    def create
      @session = Assessment::Session.find(params[:session_id])
      unless @session
        return render json: { success: false, errors: ['Оценочная сессия не найдена'] }, status: 404
      end
      if resource_collection.where(assessment_session_id: @session.id, account_id: current_account.id).any?
        return render json: { success: false, errors: ['Ваша оценка уже зарегистрирована'] }
      end
      @resource_instance.assessment_session = @session
      @resource_instance.account = current_account
      if @resource_instance.save
        render json: @resource_instance.as_json(json_resource_inclusion)
      else
        render json: { success: false, errors: @resource_instance.errors.as_json }
      end
    end

    private

    def resource_collection
      'Assessment::SessionEvaluation'.constantize
    end

    def collection_name
      'session_evaluations'
    end

    def resource_name
      'session_evaluation'
    end

    def permitted_attributes
      [
          skill_evaluations_attributes:[
              :skill_id, :comment,
              indicator_evaluations_attributes: [
                  :indicator_id, :rating_scale, :rating
              ]
          ]
      ]
    end
  end
end
