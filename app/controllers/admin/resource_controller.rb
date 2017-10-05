class Admin::ResourceController < Admin::BaseController
  load_and_authorize_resource
  include Resoursable

  before_action :set_paper_trail_whodunnit
  before_action :authenticate_user!

  helper_method :current_profile

  def index
    gon.controller_name = controller_name
  end

  def show; end

  def new
    respond_with @resource_instance
  end

  def edit
    session[:referer] = request.referer
    respond_with @resource_instance
  end

  def create
    if @resource_instance.save
      redirect_to @resource_instance, notice: "Сущность успешно создана"
    else
      render :new
    end
  end

  def update
    if @resource_instance.update_attributes(resource_params)
      redirect_to @resource_instance, notice: "Сущность успешно обновлена"
    else
      render :edit
    end
  end

  def destroy
    @resource_instance.destroy if @resource_instance
    redirect_to @resource_collection, notice: "Сущность успешно удалена"
  end

  private

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_url, :alert => exception.message
  end

  def current_profile
    return unless user_signed_in?

    @_current_profile ||= current_user.profile || current_user.build_profile

    if @_current_profile.new_record?
      @_current_profile.save(validate: false)
      @_current_profile = @_current_profile
    end

    @_current_profile
  end
end
