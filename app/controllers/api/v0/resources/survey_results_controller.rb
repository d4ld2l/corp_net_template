class Api::V0::Resources::SurveyResultsController < Api::ResourceController
  include Api::V0::Resources::SurveyResults

  def create
    survey = Survey.find(resource_params[:survey_id].to_i)
    if !survey&.published? || survey.survey_results.where(account_id: resource_params[:account_id]).count >= 1
      render json: { success: false }
      return
    end

    @resource_instance = resource_class.new(account_id: resource_params[:account_id] || current_account.id,
                                            survey: survey)

    @resource_instance.save(validate: false)

    build_answers
    if survey.complex?
      render json: { id: @resource_instance.id,
                     statistics: survey.complex_results,
                     answers_count: survey.survey_results.count,
                     success: true }
    else
      render json: { id: @resource_instance.id, success: true }
    end
  end

  private

  def resource_params
    params.require(:survey_result).permit!
  end

  def build_answers
    params[:survey_result][:survey_answers_attributes].each do |question_id, answers|
      @resource_instance.survey_answers.build(question_id: question_id.to_s.to_i,
                                              answers: answers[:answers]).save(validate: false)
    end
  end
end
