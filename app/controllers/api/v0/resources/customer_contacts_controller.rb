class Api::V0::Resources::CustomerContactsController < Api::ResourceController
  include Api::V0::Resources::CustomerContacts
  require 'parsers/xlsx/customer_contacts_xlsx_builder'
  include Commentable
  prepend_before_action :set_customer
  before_action :set_collection, only: %i[index as_xlsx]

  def index
    respond_to do |format|
      format.xlsx do
        file = Parsers::XLSX::CustomerContactsXlsxBuilder.build(@customer)
        send_file file, disposition: 'attachment'
      end
      format.json do
        render json: {
          total: @total_count,
          customer_contacts: @collection.page(page).per(per_page).as_json(json_collection_inclusion)
        }
      end
    end
  end

  def show
    render json: @resource_instance.as_json(json_resource_inclusion)
  end

  def create
    @resource_instance.customer = @customer
    if @resource_instance.save
      render json: { success: true, customer_contact: @resource_instance.as_json(json_resource_inclusion) }
    else
      render json: { success: false, errors: @resource_instance.errors }
    end
  end

  def update
    @resource_instance.customer = @customer
    if @resource_instance.update_attributes(resource_params)
      render json: { success: true, customer_contact: @resource_instance.as_json(json_resource_inclusion) }
    else
      render json: { success: false, errors: @resource_instance.errors }
    end
  end

  def destroy
    if @resource_instance.destroy
      render json: { success: true, customer_contact: @resource_instance.as_json(json_resource_inclusion) }
    else
      render json: { success: false, errors: @resource_instance.errors }
    end
  end

  private

  def search
    query = params[:q]&.dup.to_s[0..127]

    reserved_symbols = %w(+ - = && || > < ! ( ) { } [ ] ^ " ~ * ? : \\ /)

    # escaping reserved symbols
    reserved_symbols.each do |s|
      query.gsub!(s, "\\#{s}")
    end
    association_chain.search(query).records
  end

  def set_collection
    @collection ||= params[:q] ? search : association_chain
    @collection = @collection.where(customer_id: @customer_id)
    @total_count = @collection.count
    @collection = @collection.reorder(name: :asc)
    instance_variable_set("@#{ collection_name }", @collection)
  end

  def set_resource
    @resource_instance ||= CustomerContact.includes(chain_resource_inclusion).find_by(id: params[:id], customer_id: @customer_id)
    raise ActiveRecord::RecordNotFound.new(params[:path]) unless @resource_instance.present?
  end

  def set_customer
    @customer_id = params[:customer_id]
    @customer = Customer.find(@customer_id)
    raise ActiveRecord::RecordNotFound.new(params[:path]) unless @customer.present?
  end

  def permitted_attributes
    [
      :id, :name, :city, :position, :description, :skype,
      social_urls: [],
      contact_emails_attributes: %i[id kind email preferable _destroy],
      contact_phones_attributes: %i[id kind number preferable whatsapp telegram viber _destroy],
      contact_messengers_attributes: [:id, :name, :_destroy, phones: []]
    ]
  end
end
