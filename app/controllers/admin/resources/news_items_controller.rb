class Admin::Resources::NewsItemsController < Admin::ResourceController
  include Publishable
  include Commentable
  # include Paginatable
  skip_before_action :set_collection, except: :index

  def index
    @collection = @collection.page(params[:page]).per(30)

    if params[:sort_by] == 'news_categories.name' and not params[:q]
      order_settings = params[:sort_by] + ' ' + @sort_order
      @collection = @collection.left_outer_joins(:news_category).reorder(order_settings)
    else
      super
    end
  end

  def create
    if @resource_instance.save
      redirect_to @resource_instance, notice: "Новость успешно создана"
    else
      render :new
    end
  end

  def update
    if @resource_instance.update_attributes(resource_params)
      redirect_to @resource_instance, notice: "Новость успешно обновлена"
    else
      render :edit
    end
  end

  def destroy
    @resource_instance.destroy if @resource_instance
    redirect_to @resource_collection, notice: "Новость успешно удалена"
  end

  private

  def search
    @blank_stripped_params = params.to_unsafe_h.strip_blanks
    results = resource_class.search(@blank_stripped_params.dig("q", "q"), @blank_stripped_params&.dig("q"))
    @search_count = results.results.total
    results.per(1000).records
  end

  def set_collection
    @collection ||= params[:q].present? ? search : association_chain
  end

  def permitted_attributes
    super + [:news_category, :tag_list, photos_attributes:[:id, :_destroy, :file, :name]]
  end

  def association_chain
    super.reorder(created_at: :desc)
  end
end
