class Admin::Resources::EventsController < Admin::ResourceController
  include Paginatable


  def create
    @resource_instance.created_by ||= current_user
    super
  end

  def update
    @resource_instance.created_by ||= current_user
    super
  end

  private

  def permitted_attributes
    [
        :id, :name, :created_by_id, :starts_at, :ends_at, :description, :event_type_id, :place,
        event_participants_attributes: [:id, :user_id, :do_not_disturb, :email, :_destroy],
        documents_attributes: [:id, :name, :file, :remote_file_url, :_destroy]
    ]
  end
end
