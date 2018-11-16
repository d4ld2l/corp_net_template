class Api::ResourceController < Api::BaseController
  before_action :authenticate_account!
  include Resoursable

  def index
    render json: @collection.as_json(json_collection_inclusion)
  end

  def show
    render json: @resource_instance.as_json(json_resource_inclusion)
  end

  def create
    if @resource_instance.save
      render json: @resource_instance.as_json(json_resource_inclusion)
    else
      render json: { success: false, errors: @resource_instance.errors.as_json }
    end
  end

  def update
    if @resource_instance.update_attributes(resource_params)
      render json: @resource_instance.as_json(json_resource_inclusion)
    else
      render json: { success: false, errors: @resource_instance.errors.as_json }
    end
  end

  def destroy
    @resource_instance.destroy if @resource_instance
    render json: { success: true }
  end

  private

  def set_resource
    @resource_instance ||= resource_collection.includes(chain_resource_inclusion).find(params[:id])
    raise ActiveRecord::RecordNotFound.new(params[:path]) unless @resource_instance.present?
  end
end
