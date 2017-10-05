class Api::ResourceController < Api::BaseController
  include Resoursable

  before_action :authenticate_user!

  def index
    render json: @collection
  end

  def show
    render json: @resource_instance
  end

  def create
    if @resource_instance.save
      render json: @resource_instance
    else
      render json: {success: false}
    end
  end

  def update
    if @resource_instance.update_attributes(resource_params)
      render json: @resource_instance
    else
      render json: {success: false}
    end
  end

  def destroy
    @resource_instance.destroy if @resource_instance
    render json: {success:true}
  end

  rescue_from ActiveRecord::RecordNotFound do
    flash[:error] = "Сущность не сохранена! Одна или несколько связанных записей не найдены. Попробуйте повторить действие."
    render json: {success: false}
  end

end
