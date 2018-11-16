class Api::V0::Resources::AccountPhotosController < Api::ResourceController
  include Likable

  before_action :set_resource, except: :index

  def index
    render json:
    {
       account_photos: @collection.as_json(current_account_id: current_account.id)
    }
  end

  def show
    render json: @resource_instance.as_json(current_account_id: current_account.id)
  end

  def create
    if @resource_instance.save
      render json: { success: true, account_photo: @resource_instance.as_json(current_account_id: current_account.id) }
    else
      render json: { success: false, errors: @resource_instance.errors }
    end
  end

  def update
    if @resource_instance.update_attributes(resource_params)
      render json: { success: true, account_photo: @resource_instance.as_json(current_account_id: current_account.id) }
    else
      render json: { success: false, errors: @resource_instance.errors }
    end
  end

  def set_as_avatar
    @resource_instance.ensure_account_has_an_avatar
    render json: { success: true }
  end

  # def destroy
  # end

  private

  def set_collection
    @collection = AccountPhoto.where(account_id: params[:account_id])
  end

  def set_resource
    @resource_instance ||= AccountPhoto.find_by(id: params[:id], account_id: params[:account_id])
    raise ActiveRecord::RecordNotFound, params[:path] unless @resource_instance.present?
  end

  def build_resource
    @resource_instance ||= resource_collection.new((action_name == 'create') ? resource_params.merge(account_id: params[:account_id]) : {})
    instance_variable_set("@#{ resource_name }", @resource_instance)
  end

  def permitted_attributes
    [
        "photo",
        "account_id",
        "archived_at",
        "cropped_photo",
        "crop_info": ["x", "y", "width", "height"]
    ]
  end

end
