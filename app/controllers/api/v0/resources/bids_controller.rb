class Api::V0::Resources::BidsController < Api::ResourceController
  include Commentable
  include Api::V0::Resources::Bids

  before_action :set_resource, only: %i[update show destroy states allowed_states change_state build]
  skip_before_action :authenticate_account!, only: [:build]
  before_action :set_collection, only: %i[index author executor]

  helper_method :current_stage

  def show
    render json: @resource_instance.as_json(json_resource_inclusion)
  end

  def create
    @resource_instance.author_id = current_account&.id unless @resource_instance.author_id
    @resource_instance.creator_id = current_account&.id unless @resource_instance.creator_id
    @resource_instance.comments.each do |c|
      c.account_id = current_account.id unless c.persisted?
    end
    if @resource_instance.save
      render json: @resource_instance.as_json(json_resource_inclusion)
    else
      render json: { success: false, errors: @resource_instance.errors.messages }
    end
  end

  def update
    if current_stage.stage_is_a?(:new) || current_stage.stage_is_a?(:revision_required)
      @resource_instance.comments.each do |c|
        c.account_id = current_account.id unless c.persisted?
      end
      if @resource_instance.update_attributes(resource_params)
        render json: @resource_instance.as_json(json_resource_inclusion)
      else
        render json: { success: false, errors: @resource_instance.errors.messages }
      end
    else
      render json: { success: false, errors: @resource_instance.errors.messages }
    end
  end

  def import
    require 'parsers/xlsx/byod_xlsx_parser'
    p = Parsers::XLSX::ByodXlsxParser.new(params[:documents_xlsx_parser].path)
    begin
      p.create_bids
    rescue StandardError
      return render json: { success: false }
    end
    render json: { success: true }
  end

  def states
    render json: @resource_instance.all_stages
  end

  def allowed_states
    render json: @resource_instance.allowed_stages
  end

  def change_state
    response = if @resource_instance.apply_state(state_params[:state])
                 { success: true, resource_name => @resource_instance, stage: @resource_instance&.bid_stage&.name }
               else
                 { success: false, resource_name => @resource_instance,
                   errors: @resource_instance&.errors,
                   stage: @resource_instance&.bid_stage&.name }
               end

    render json: response
  end

  def author
    set_counters(:as_author)
    @collection = @collection.where(author: current_account)
    render json: {
      counters: @counters,
      data: @collection.page(page).per(per_page).as_json(json_collection_inclusion)
    }
  end

  def executor
    set_counters(:as_executor)
    @collection = @collection.where(manager: current_account)
    render json: {
      counters: @counters,
      data: @collection.page(page).per(per_page).as_json(json_collection_inclusion)
    }
  end

  def current_stage
    @resource_instance.bid_stage
  end

  def build
    respond_to do |format|
      format.docx do
        send_file @resource_instance.build_content_for_docx.path,
                  filename: 'report.docx', disposition: 'attachment'
      end
    end
  end

  private

  def set_counters(scope)
    if scope
      res = BidStage.send(scope, current_account&.id).select('bid_stages.*, count(bids.id) as bids_count')
      res = res.where('bids.service_id = ?', params[:service_id]) if params[:service_id]
      res = res.where('bids.manager_id = ?', params[:manager_id]) if params[:manager_id]
      res = res.where('bids.created_at >= ?', params[:created_from]) if params[:created_from]
      res = res.where('bids.created_at <= ?', params[:created_to]) if params[:created_to]
      res = res.group(:id)
    else
      res = BidStage.all.select('bid_stages.*, count(bids.id) as bids_count').group(:id)
    end
    res = res.map do |x|
      {
        codes: [x.code],
        name: x.name,
        bids_count: x.bids_count
      }
    end
    @counters = []
    res.each do |x|
      if i = @counters.map { |x| x[:name] }.index(x[:name])
        @counters[i][:codes] += x[:codes]
        @counters[i][:bids_count] += x[:bids_count]
      else
        @counters << x
      end
    end
  end

  def filter(chain)
    chain = chain.where(service_id: params[:service_id]) if params[:service_id]
    chain = chain.where(manager_id: params[:manager_id]) if params[:manager_id]
    chain = chain.where('bids.created_at >= ?', params[:created_from]) if params[:created_from]
    chain = chain.where('bids.created_at <= ?', params[:created_to]) if params[:created_to]
    chain = chain.left_outer_joins(bids_bid_stage: [:bid_stage]).where(bids_bid_stages: { bid_stages: { code: params[:bid_stage_codes].split(',') } }) if params[:bid_stage_codes]
    chain
  end

  def search
    resource_class.search(params[:query].strip_blanks).records.includes(:author, :manager, bids_bid_stage: :bid_stage)
  end

  def set_collection
    @collection ||= params[:q] ? search : association_chain
    @collection = filter(@collection)
    @collection.reorder(created_at: :desc)
    instance_variable_set("@#{collection_name}", @collection)
  end

  def association_chain
    super.reorder(created_at: :desc)
  end

  def state_params
    allowed_states = @resource_instance.all_stages

    params.permit(:id, :state, :subdomain, :format, resource_name.to_sym => {})
    params.delete(:state) unless params[:state].in? allowed_states
    params
  end

  def permitted_attributes
    [:service_id, :author_id, :creator_id, :creator_comment, :creator_position, :matching_user_id, :assistant_id, :manager_id, :manager_position, :legal_unit_id,
     bids_bid_stage_attributes: %i[id bid_stage_id],
     representation_allowance_attributes: [
       :id, information_about_participant_attributes: [
         :id, :representation_allowance_id, :organization_name,
         :participant_organization, :project_id, :customer_id,
         customer_attributes: [:name],
         participants_attributes: %i[id account_id position type_of_participant information_about_participant_id _destroy name responsible],
         other_participants_attributes: [:id, :counterparty_id, :_destroy,
                                         counterparty_attributes: %i[id customer_id responsible name position]]
       ],
            meeting_information_attributes: [:id, :comment, :representation_allowance_id, :starts_at,
                                             :place, :address, :aim, :result, :amount, :check,
                                             check_attributes: %i[id file name photo_attachable_id photo_attachable_type],
                                             base64_document_attributes: %i[id file name base64_doc_attachable_id base64_doc_attachable_type]]
     ],
     byod_information_attributes: [
       :id, :byod_type, :project_id, :device_model, :device_inventory_number, :compensation_amount, :_destroy,
       documents_attributes: %i[id file name _destroy]
     ],
     team_building_information_attributes: [
         :id, :project_id, :city, :number_of_participants, :event_format, :event_date, :additional_info, :approx_cost, :additional_info,
         team_building_information_legal_units_attributes: %i[id legal_unit_id _destroy],
         team_building_information_accounts_attributes: %i[id account_id _destroy]
     ],
     bonus_information_attributes: [
       :id, :bonus_reason_id, :additional, bonus_information_participants_attributes: %i[id account_id sum period_start period_end legal_unit_id charge_code misc bonus_reason_id _destroy],
       bonus_information_approvers_attributes: %i[id account_id _destroy]
     ],
     comments_attributes: [:id, :account_id, :body, :commentable_id, :commentable_type, :_destroy, documents_attributes: %i[id file name _destroy]]]
  end
end
