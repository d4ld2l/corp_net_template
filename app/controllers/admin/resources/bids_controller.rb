class Admin::Resources::BidsController < Admin::ResourceController
  include Paginatable
  before_action :set_resource, only: %i[edit update show destroy build]
  before_action :set_account_url, only: %i[new edit]
  before_action :build_comment, only: :show

  layout false, only: :build

  def index
    if params[:sort_by] and not params[:query]
      @collection = case params[:sort_by]
                      when 'service_name'
                        @collection
                            .includes(:service)
                            .reorder("services.name #{@sort_order}")
                      when 'status'
                        @collection
                            .includes(bids_bid_stage: :bid_stage)
                            .reorder("bid_stages.name #{@sort_order}")

                      when 'author_name'
                        @collection
                            .joins(:author)
                            .reorder("accounts.surname #{@sort_order}")

                      when 'manager_name'
                        @collection
                            .joins(:manager)
                            .reorder("accounts.surname #{@sort_order}")
                      else
                        order_settings = params[:sort_by] + ' ' + @sort_order
                        @collection = @collection.reorder(order_settings)
                    end
    end
  end

  def new
    @accounts = Account.all.map {|u| [u.full_name, u.id]}
    @service = Service.where(id: params[:service_id]).first
    if @service
      case @service.name
        when "Оформление представительских расходов"
          @resource_instance.build_representation_allowance
        when "Bring your own device"
          @resource_instance.build_byod_information
      end
    end
    super
  end

  def edit
    @accounts = Account.all.map {|u| [u.full_name, u.id]}
    super
  end

  def create
    @resource_instance.author_id = current_account&.id unless @resource_instance.author_id
    @resource_instance.creator_id = current_account&.id unless @resource_instance.creator_id
    super
  end

  def build
    respond_to do |format|
      format.docx do
        send_file @resource_instance.build_content_for_docx.path,
                  filename: "report.docx", disposition: 'attachment'
      end
    end
  end

  def import
    require 'parsers/xlsx/byod_xlsx_parser'
    p = Parsers::XLSX::ByodXlsxParser.new(params.dig(:bids, :documents_xlsx_parser).path)
    begin
      p.create_bids
      redirect_to resource_class, notice: 'Данные успешно загружены'
    rescue
      redirect_to resource_class, error: 'При загрузке данных произошла ошибка'
    end
  end

  def byod_report
    byod_service_id = Service.where(name: 'Bring your own device').first.id
    collection = Bid.where(service_id: byod_service_id).order(created_at: :desc)
    filename = "BYOD_отчёт_#{Date.today.to_s}.xlsx"
    file = Parsers::XLSX::BidsParser.build(collection)
    send_file file, filename: filename, type: "application/xlsx"
  end

  def representation_allowance_report
    representation_allowance_service_id = Service.where(name: 'Оформление представительских расходов').first.id
    collection = Bid.where(service_id: representation_allowance_service_id).order(created_at: :desc)
    filename = "Отчёт_по_представительским_расходам_#{Date.today.to_s}.xlsx"
    file = Parsers::XLSX::RepresentationAllowancesParser.build(collection)
    send_file file, filename: filename, type: "application/xlsx"
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

  def permitted_attributes
    [:service_id, :creator_id, :creator_position, :creator_comment, :matching_user_id, :assistant_id, :author_id, :manager_id, :manager_position, :legal_unit_id, bids_bid_stage_attributes: %i[id bid_stage_id],
     representation_allowance_attributes:
         [:id, information_about_participant_attributes: [:id, :representation_allowance_id, :organization_name,
                                                          :participant_organization, :project_id, :customer_id,
                                                          participants_attributes: %i[id account_id position type_of_participant responsible
                                                                                                      information_about_participant_id _destroy name],
                                                          other_participants_attributes: [:id, :counterparty_id, :_destroy,
                                                                                          counterparty_attributes: %i[id customer_id responsible name position]]],
          meeting_information_attributes: [:id, :comment, :representation_allowance_id, :starts_at,
                                           :place, :address, :aim, :result, :amount, :check,
                                           check_attributes: %i[id file name photo_attachable_id photo_attachable_type],
                                           base64_document_attributes: %i[id file name base64_doc_attachable_id base64_doc_attachable_type]]],
     byod_information_attributes: [
         :id, :byod_type, :project_id, :device_model, :device_inventory_number, :compensation_amount, :_destroy,
         documents_attributes: [:id, :file, :name, :_destroy]
     ],
     comments_attributes: [:id, :profile_id, :body, :commentable_id, :commentable_type, :_destroy, documents_attributes: [:id, :file, :name, :_destroy]]]
  end

  def set_account_url
    gon.account_url = accounts_url
  end

  def build_comment
    @comment = @resource_instance.comments.build
  end
end
