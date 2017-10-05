class Api::V0::Resources::NewsController < Api::ResourceController
  include AasmStates
  include Commentable

  def index
    render json: @collection.as_json(methods: [:comments_count, :tags, :author], include: { tags:{}, news_category:{}, community:{}, documents:{},
                                                                                   photos:{}, comments:{
            include: {user:{include:{profile:{}}}}
        }})
  end

  def show
    render json: @resource_instance.as_json(methods: [:comments_count, :tags], include: { tags:{}, news_category:{}, community:{}, documents:{},
                                                      photos:{}, comments:{
            include: {user:{include:{profile:{}}}}
        }})
  end

  def create
    @resource_instance.user ||= current_user
    if @resource_instance.save
      render json: @resource_instance.as_json(methods: [:comments_count, :tags], include: { tags:{}, news_category:{}, community:{}, documents:{},
                                                                                            photos:{}, comments:{
              include: {user:{include:{profile:{}}}}
          }})
    else
      render json: {success: false}
    end
  end

  def update
    @resource_instance.user ||= current_user
    if @resource_instance.update_attributes(resource_params)
      render json: @resource_instance.as_json(methods: [:comments_count, :tags], include: { tags:{}, news_category:{}, community:{}, documents:{},
                                                                                            photos:{}, comments:{
              include: {user:{include:{profile:{}}}}
          }})
    else
      render json: {success: false}
    end
  end

  private

  def association_chain
    result = resource_collection
    if news_items_scope
      if params[:community_id] && news_items_scope == 'only_by_community'
        result = result.send(news_items_scope).where(community_id: params[:community_id])
      else
        result = result.send(news_items_scope)
      end
    else
      result = result.only_not_by_community
    end
    if news_items_status
      result = result.send("only_#{news_items_status}")
    else
      result = result.only_published
    end
    if params[:news_category_id]
      result = result.where(news_category_id: params[:news_category_id])
    end
    if params[:created_after]
      result = result.created_after(Date.parse(params[:created_after]))
    end
    if params[:created_before]
      result = result.created_before(Date.parse(params[:created_before]))
    end
    if params[:published_after]
      result = result.published_after(Date.parse(params[:published_after]))
    end
    if params[:published_before]
      result = result.published_before(Date.parse(params[:published_before]))
    end
    if params[:with_tags]
      result = result.tagged_with(params[:with_tags].split(','))
    end
    result.order(created_at: :desc)
  end

  def news_items_scope
    %w(all only_by_community only_not_by_community).include?(params[:scope]) ? params[:scope] : nil
  end

  def news_items_status
    %w(published unpublished draft archived).include?(params[:state]) ? params[:state] : nil
  end

  def collection_name
    @collection_name = 'news_items'
  end

  def permitted_attributes
    [
        :user_id, :title, :preview, :body, :tags, :published_at,
        :on_top, :news_category_id, news_groups: [],
        photos: [:name, :file, :remote_file_url], documents: [:name, :file, :remote_file_url]
    ]
  end
end
