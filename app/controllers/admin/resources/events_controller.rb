class Admin::Resources::EventsController < Admin::ResourceController
  include Paginatable


  def create
    @resource_instance.created_by_id = current_account.id unless @resource_instance.created_by_id
    super
  end

  def update
    @resource_instance.created_by_id = current_account.id unless @resource_instance.created_by_id
    super
  end

  def index 
    @collection = @collection.includes(:event_type, :created_by)
    super
  end 

  private

  def permitted_attributes
    [
        :id, :name, :created_by_id, :starts_at, :ends_at, :description, :event_type_id, :place, :available_for_all,
        event_participants_attributes: [:id, :account_id, :do_not_disturb, :email, :_destroy],
        documents_attributes: [:id, :name, :file, :remote_file_url, :_destroy]
    ]
  end
end
