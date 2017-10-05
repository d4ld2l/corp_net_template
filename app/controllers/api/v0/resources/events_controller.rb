class Api::V0::Resources::EventsController < Api::ResourceController
  def index
    render json: @collection.as_json(methods:[:participants_count, :participants, :created_by], include:{event_type:{}, documents:{}})
  end

  def show
    render json: @resource_instance.as_json(methods:[:participants_count, :participants, :created_by], include:{event_type:{}, documents:{}})
  end

  def create
    @resource_instance.created_by ||= current_user
    if @resource_instance.save
      render json: @resource_instance.as_json(methods:[:participants_count, :participants, :created_by], include:{event_type:{}, documents:{}})
    else
      render json: {success: false}
    end
  end

  def update
    @resource_instance.created_by ||= current_user
    if @resource_instance.update_attributes(resource_params)
      render json: @resource_instance.as_json(methods:[:participants_count, :participants, :created_by], include:{event_type:{}, documents:{}})
    else
      render json: {success: false}
    end
  end

  private

  def association_chain
    result = resource_collection
    if params[:event_type_id]
      result = result.where(event_type_id: params[:event_type_id])
    end
    if params[:creator_id]
      result = result.where(created_by_id: params[:creator_id])
    end
    if params[:from_time]
      result = result.where('? <= ends_at', Time.parse(params[:from_time]))
    end
    if params[:to_time]
      result = result.where('? <= starts_at', Time.parse(params[:to_time]))
    end
    if params[:in_time]
      result = result.where('? >= starts_at and ? <= ends_at', Time.parse(params[:in_time]), Time.parse(params[:in_time]))
    end
    result.decorate
  end

  def build_resource
    @resource_instance ||= resource_collection.new((action_name == 'create') ? resource_params : {}).decorate
    instance_variable_set("@#{ resource_name }", @resource_instance)
  end

  def permitted_attributes
    [
        :id, :name, :created_by_id, :starts_at, :ends_at, :description, :event_type_id, :place,
        event_participants: [:id, :email, :user_id, :do_not_disturb, :_destroy],
        documents_attributes:[:id, :file, :remote_file_url, :name, :_destroy]
    ]
  end
end
