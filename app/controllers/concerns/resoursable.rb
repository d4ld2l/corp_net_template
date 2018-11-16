module Resoursable
  extend ActiveSupport::Concern

  included do
    before_action :set_collection, only: [:index]
    before_action :build_resource, only: [:new, :create]
    before_action :set_resource, only: [:edit, :update, :show, :destroy]
    before_action :set_paper_trail_whodunnit

    helper_method :resource_class, :per_page, :total_pages
  end

  private


  # Включения и цепочки

  def chain_collection_inclusion
    @chain_collection_inclusion ||= {}
  end

  def chain_resource_inclusion
    @chain_resource_inclusion ||= {}
  end

  def json_collection_inclusion
    @json_collection_inclusion ||= {}
  end

  def json_resource_inclusion
    @json_resource_inclusion ||= {}
  end


  # Пагинация
  
  def total_pages
    resource_class.count
  end

  def page
    params[:page] || 1
  end

  def per_page
    params[:per_page] || default_per_page
  end

  def default_per_page
    15
  end


  # Хелперы

  def permitted_attributes
    @permitted_attributes ||= resource_collection.attribute_names - %w( id created_at updated_at)
  end

  def collection_name
    @collection_name ||= controller_name
  end

  def resource_name
    @resource_name ||= collection_name.singularize
  end

  def resource_class(variable = nil)
    if variable
      super variable
    else
      @resource_class ||= controller_name.singularize.classify.constantize
    end
  end

  def resource_collection
    @resource_collection ||= resource_name.classify.constantize
  end

  def resource_params
    @resource_params ||= params.require(resource_name.to_sym).permit(permitted_attributes)
  end


  # Работа с коллекцией или записью

  def association_chain
    resource_collection.all.order(updated_at: :desc).includes(chain_collection_inclusion)
  end

  def set_collection
    @collection ||= params[:q] ? search : association_chain
    instance_variable_set("@#{ collection_name }", @collection)
  end

  def build_resource
    @resource_instance ||= resource_collection.new((action_name == 'create') ? resource_params : {})
    instance_variable_set("@#{ resource_name }", @resource_instance)
  end

  def set_resource
    raise NotImplementedError, "resoursable must implement #set_resource"
  end


  # Поиск

  def search
    results = resource_class.search(params[:q], params&.to_unsafe_h)
    @search_count = results.results.total
    results.page(page).per(per_page).records.all
  end
end