class Admin::Resources::ServicesController < Admin::ResourceController
  include Publishable
  include Paginatable

  def index
    @collection = @collection.includes(:service_group)
    super
  end


  def edit
    super
  end

  def update
    if @resource_instance.update_attributes(resource_params)
      redirect_to @resource_instance, notice: "Сервис успешно обновлен"
    else
      render :edit
    end
  end

  def destroy
    @resource_instance.destroy if @resource_instance
    redirect_to @resource_collection, notice: "Сервис удалён"
  end

  private

  def search
    @blank_stripped_params = params.to_unsafe_h.strip_blanks
    results = resource_class.search(@blank_stripped_params.dig("q", "q"), @blank_stripped_params&.dig("q"))
    @search_count = results.results.total
    results.per(1000).records
  end

  def permitted_attributes
    [:name, :description, :service_group_id, :process_description, :bid_stages_group_id, :supporting_documents, :is_bid_required,
     :is_provided_them, :order_service, :results, :term_for_ranting, :restrictions,
     contacts_services_attributes: %i[id _destroy service_id contact_id],
     documents_attributes: %i[id name file _destroy document_attachable_id document_attachable_type],
     notifications_attributes: %i[id body notice_id notice_type show_notification _destroy]]
  end
end
