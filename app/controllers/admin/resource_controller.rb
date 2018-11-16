class Admin::ResourceController < Admin::BaseController
  #load_and_authorize_resource
  include Resoursable
  include IndexSortable

  before_action :set_paper_trail_whodunnit
  before_action :change_sort_order, only: :index 

  helper_method :current_profile

  def index
    gon.controller_name = controller_name

    if params[:sort_by] and not params[:q]
      order_settings = params[:sort_by] + ' ' + @sort_order
      @collection = @collection.reorder(order_settings)
    end 
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
    redirect_to resource_collection, notice: "Сущность успешно удалена"
  end

  private

  def search
    @blank_stripped_params = params.to_unsafe_h.strip_blanks
    super
  end

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_url, :alert => exception.message
  end

  def current_profile
    return unless user_signed_in?

    @_current_profile ||= current_user.profile || current_user.build_profile(user: current_user)

    if @_current_profile.new_record? && !(current_user.supervisor? && current_tenant != current_user.company)
      @_current_profile.save(validate: false)
      @_current_profile = @_current_profile
    end

    @_current_profile
  end

  def set_resource
    @resource_instance ||= resource_collection.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    # TODO: move redirect to responder
    @resource_instance = nil
    flash[:warning] = "#{ resource_collection.model_name.human } &mdash; не удалось найти запись"
    redirect_to :back
  ensure
    instance_variable_set("@#{ resource_name }", @resource_instance)
  end
end
