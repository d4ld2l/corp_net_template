class Admin::Resources::SurveysController < Admin::ResourceController
  before_action :set_resource, only: %i[edit update show publish unpublish archived destroy]
  before_action :init_question, only: %i[new edit]
  before_action :set_creator_user, only: %i[new create]
  before_action :set_editor_user, only: %i[edit update]
  before_action :add_participants_from_mailing_list, only: %i[create update]
  include Paginatable

  def index
    # @collection = params.dig(:q, :s)&.include?('participants_count') ? @q.result.sort_by_participants(asc: params[:q][:s].split.last).page(params[:page]).per(30) : @q.result.order(updated_at: :desc).page(params[:page]).per(30)
    if params[:sort_by] and not params[:q]
      @collection = case params[:sort_by]
        when 'count_participants'
          @collection = @collection
            .left_joins(:survey_results)
            .group(:id)
            .reorder("COUNT(survey_results.account_id) #{@sort_order}")

        when 'publisher.surname'
          @collection = @collection
            .includes(:publisher)
            .reorder("accounts.surname #{@sort_order}")

        else 
          order_settings = params[:sort_by] + ' ' + @sort_order
          @collection = @collection.reorder(order_settings)
        end

    end  
  end

  def show
    redirect_back fallback_location: {action: :index} if @resource_instance.archived?
  end

  def publish
    @resource_instance.to_published
    @resource_instance.assign_attributes(publisher: current_account,
                                         published_at: DateTime.current)
    @resource_instance.save(validate: false)
    flash[:notice] = t('.flash.notice')
    respond_with @resource_instance
  end

  def unpublish
    @resource_instance.to_unpublished
    @resource_instance.assign_attributes(unpublisher: current_account,
                                         unpublished_at: DateTime.current)
    @resource_instance.save(validate: false)
    flash[:notice] = t('.flash.notice')
    respond_with @resource_instance
  end

  def archived
    @resource_instance.to_archived
    @resource_instance.save(validate: false)
    flash[:notice] = t('.flash.notice')
    respond_with resource_class
  end

  private

  def set_collection
    @collection ||= params[:query] ? search : association_chain
    instance_variable_set("@#{ collection_name }", @collection)
  end


  def search
    @blank_stripped_params = params.to_unsafe_h.strip_blanks
    results = resource_class.search(@blank_stripped_params.dig("query", "q"), @blank_stripped_params&.dig("query"))
    @search_count = results.results.total
    results.per(1000).records
  end

  def association_chain
    if current_account.role?(:admin)
      super.where.not(state: :archived).reorder(created_at: :desc)
    else
      super.where(state: :published).reorder(created_at: :desc)
    end
  end

  def permitted_attributes
    [:name, :symbol, :note, :document, :survey_type, :anonymous, :background, :ends_at, :available_to_all,
     documents_attributes: [:id, :file, :name, :_destroy],
     questions_attributes: [:id, :_destroy, :image, :wording, :ban_own_answer, :position, :question_type,
                            offered_variants_attributes: %i[id _destroy wording image]], mailing_list_ids: [], survey_participants_attributes: [:id, :_destroy, :user_id]]
  end

  def init_question
    count = @resource_instance.questions.exists? ? @resource_instance.questions.count : 0

    (1 - count).times do
      @resource_instance.questions.build
    end
  end

  def set_creator_user
    @resource_instance.assign_attributes(creator: current_account)
  end

  def set_editor_user
    @resource_instance.assign_attributes(editor: current_account)
  end

  def add_participants_from_mailing_list
    if params[:mailing_list_ids]
      params[:mailing_list_ids].each do |ml|
        participants_from_params = params.dig(:survey, :survey_participants_attributes)&.keep_if{ |k,v| v[:_destroy] != "1"}&.values&.map{|x| x[:user_id] || SurveyParticipant.find_by_id(x[:id])&.user_id}
        participants = MailingList.find_by_id(ml).profile_ids - Profile.where(user_id: participants_from_params).ids
        @resource_instance.participants_from_mailing_list_participants(participants) if participants.present?
      end
    end
  end
end
