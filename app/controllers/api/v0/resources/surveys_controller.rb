class Api::V0::Resources::SurveysController < Api::ResourceController
  include Api::V0::Resources::Surveys

  before_action :set_resource, only: %i[edit update show download destroy]
  before_action :set_creator_account, only: %i[new create]
  before_action :set_editor_account, only: %i[new create edit update]
  before_action :set_collection, only: :index
  before_action :filter_resource, only: %i[index]

  def index
    render json: {new_count: @new_count,
                  passed_count: @passed_count,
                  my_count: @my_count,
                  surveys: @collection.as_json(json_collection_inclusion)
    }

  end

  def show
    render json: @resource_instance.decorate.as_json(json_resource_inclusion)
  end

  def create
    if @resource_instance.save
      render json: @resource_instance.decorate.as_json(json_resource_inclusion)
    else
      render json: {success: false, errors: @resource_instance.errors.as_json}
    end
  end

  def update
    if @resource_instance.update(resource_params, current_account)
      render json: @resource_instance.decorate.as_json(json_resource_inclusion)
    else
      render json: {success: false, errors: @resource_instance.errors.as_json}
    end
  end

  def download
    filename = "Опрос. #{@resource_instance&.name}.xlsx"
    file = Parsers::XLSX::SurveyResultParser.build(@resource_instance)
    send_file file, filename: filename, type: "application/xlsx"
  end

  private

  def set_creator_account
    @resource_instance.assign_attributes(creator: current_account)
  end

  def set_editor_account
    @resource_instance.assign_attributes(editor: current_account)
  end

  def filter_resource
    @collection = case params[:scope]
      when 'new'
        @collection.new_surveys(current_account&.id)
      when 'passed'
        @collection.passed_surveys(current_account&.id)
      when 'created'
        @collection.available_for_account_as_creator(current_account&.id)
      else
        @collection
    end
    instance_variable_set("@#{ collection_name }", @collection)
  end

  def search
    query = params[:q]&.dup.to_s
    resource_class.search(query, {"q" => query}).records.all.available_for_account(current_account&.id)
  end

  def association_chain
    result = super.reorder(published_at: :desc).available_for_account(current_account&.id)
    result.where(state: survey_states) if survey_states
    result
  end

  def survey_states
    params[:state].split(',') if params[:state] && params[:state].split(',').all? { |x| Survey.aasm.states.map(&:name).include?(x&.to_sym) }
  end

  def set_collection
    @new_count = Survey.new_surveys(current_account&.id).count
    @passed_count = Survey.passed_surveys(current_account&.id).count
    @my_count = Survey.available_for_account_as_creator(current_account&.id).count
    @collection ||= params[:q] ? search : association_chain
    @collection = @collection.page(page).per(per_page)
    instance_variable_set("@#{ collection_name }", @collection)
  end

  def permitted_attributes
    [:name, :symbol, :note, :document, :survey_type, :anonymous, :background, :ends_at, :available_to_all, :state,
     documents_attributes: [:id, :file, :name, :_destroy],
     questions_attributes: [:id, :_destroy, :image, :wording, :ban_own_answer, :position, :question_type,
                            offered_variants_attributes: [:id, :_destroy, :wording, :image, :position]], survey_participants_attributes: [:id, :_destroy, :account_id]]
  end
end
