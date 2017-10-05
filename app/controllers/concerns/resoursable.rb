module Resoursable
  extend ActiveSupport::Concern

  included do
    before_action :set_collection, only: :index
    before_action :build_resource, only: [:new, :create]
    before_action :set_resource, only: [:edit, :update, :show, :destroy]

    helper_method :resource_class, :per_page, :total_pages
  end

  private
  
  def total_pages
    resource_class.count
  end

  def page
    params[:page]
  end

  def per_page
    params[:per_page] || default_per_page
  end

  def association_chain
    resource_collection.all
  end

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
    params.require(resource_name.to_sym).permit(permitted_attributes)
  end

  def set_collection
    @collection ||= params[:q] ? quick_search : association_chain
    instance_variable_set("@#{ collection_name }", @collection)
  end

  def build_resource
    @resource_instance ||= resource_collection.new((action_name == 'create') ? resource_params : {})
    instance_variable_set("@#{ resource_name }", @resource_instance)
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

  def quick_search
    query = params[:q]&.dup.to_s
  
    reserved_symbols = %w(+ - = && || > < ! ( ) { } [ ] ^ " ~ * ? : \ /)
  
    # escaping reserved symbols
    reserved_symbols.each do |s|
      query.gsub!(s, "\\#{s}")
    end
  
    # TODO: буква Ë
  
    @quick_search ||= resource_class.search(body:{
      query:{
        bool: {
          should: [
                    {
                      query_string: {
                        query: "*#{query}*",
                      }
                    },
                    {
                      query_string: {
                        query: query.present? ? "#{query}~2" : query,
                        fuzzy_prefix_length: 2,
                      }
                    },
                  ]
        }
      }
    })
  end
end