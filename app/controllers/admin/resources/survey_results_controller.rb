class Admin::Resources::SurveyResultsController < Admin::ResourceController
  before_action :init_parent_resource, only: %i[index show download]

  def index
    @collection = @parent_resource.questions
    @grouped = []
    @collection.each do |question|
      answer = {}
      question.offered_variants.each do |var|
        answer["#{var.wording} - #{var.users_count}"] = var.users_percentage
      end
      answer['question_wording'] = question.wording
      answer["Свой ответ - #{question.own_answer_count}"] = question.own_answer_percentage
      @grouped << answer
    end
  end

  def show
    @resource_instance = @parent_resource.survey_results.find(params[:id])
  end

  def download
    @collection = @parent_resource.survey_results
    filename = "Опрос. #{@parent_resource&.name}.xlsx"
    file = Parsers::XLSX::SurveyResultParser.build(@parent_resource)
    send_file file, filename: filename, type: "application/xlsx"
  end

  private

  def init_parent_resource
    @parent_resource = Survey.find(params[:survey_id])
  end
end
