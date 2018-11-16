class Api::V0::Resources::FeedController < Api::ResourceController
  include Likable
  include Post::Favoritable
  include Api::V0::Resources::Feed
  append_before_action :filter_resource, only: %i[index]


  def index
    render json: @collection.as_json(json_collection_inclusion)
  end

  def show
    render json: @resource_instance.as_json(json_resource_inclusion)
  end

  def create
    @resource_instance.author_id = current_account.id
    super
  end

  def update
    @resource_instance.edited_at = DateTime.now
    super
  end

  private

  def by_scope(collection)
    if params[:scope] == 'popular'
      collection = collection.reorder(likes_count: :desc, comments_count: :desc, created_at: :desc)
    end
    if params[:scope] == 'favorite'
      collection = collection.favorites(current_account.id)
    end
    if params[:scope] == 'my'
      collection = collection.only_my(current_account.id)
    end
    if params[:scope] == 'by_communities'
      collection = collection.by_communities
    end
    collection
  end

  def search_by_tags(collection)
    if params[:with_tags]
      tags = params[:with_tags].split(',')
      collection.tagged_with(tags, wild: true, any: true)
    else
      collection
    end
  end

  def set_collection
    @collection ||= params[:q] ? search : association_chain
    instance_variable_set("@#{ collection_name }", @collection)
  end

  def search
    query = params[:q]&.dup.to_s[0..127]
    reserved_symbols = %w(+ - = && || > < ! ( ) { } [ ] ^ " ~ * ? : \\ /)
    reserved_symbols.each do |s|
      query.gsub!(s, "\\#{s}")
    end

    resource_collection.search(query).includes(chain_collection_inclusion)
  end

  def association_chain
    super.includes(chain_collection_inclusion).order(created_at: :desc)
  end

  def filter_resource
    @collection = @collection.limit(params[:limit]) if params[:limit]
    @collection = @collection.offset(params[:offset]) if params[:offset]
    @collection = by_scope(@collection)
    @collection = search_by_tags(@collection)
    @collection
  end

  def collection_name
    'post'
  end

  def resource_class(variable = nil)
    if variable
      super variable
    else
      Post
    end
  end

  def permitted_attributes
    [:id, :name, :body, :community_id, :allow_commenting,
     photos_attributes: %i[id name file _destroy],
     documents_attributes: %i[id name file _destroy]]
  end
end
