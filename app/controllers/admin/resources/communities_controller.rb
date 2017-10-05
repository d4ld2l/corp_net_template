class Admin::Resources::CommunitiesController < Admin::ResourceController
  include AasmStates
  include Autocompletable

  respond_to :html, :js

  layout false, only: [:subscribe, :unsubscribe, :news_index, :search_news_by_tag,
                                      :create_news, :update_news, :render_form, :apply]
  before_action :set_resource, only: [:edit, :update, :show, :destroy,
                                      :subscribe, :unsubscribe, :news_index, :create_news,
                                      :allowed_states, :change_state, :user_index, :render_form,
                                      :update_news, :apply, :search_news_by_tag]
  before_action :set_collection, only: [:index, :subscribe, :unsubscribe, :apply]
  before_action :init_news, only: [:show, :create_news]
  before_action :init_notification, only: :show
  before_action :init_comment, only: [:show, :search_news_by_tag, :news_index]

  include Paginatable
  def create
    @resource_instance = current_user.communities.build(resource_params)
    @resource_instance.communities_users.build(user: current_user)
    super
  end

  def subscribe
    sub = current_user.communities_users.where(community: @resource_instance).first_or_initialize
    sub.assign_attributes(status: :accepted)
    sub.save

    respond_with @collection
  end

  def unsubscribe
    current_user.communities_users.where(community: @resource_instance).first.update(status: :deleted)
    respond_with @collection
  end

  def apply
    sub = @resource_instance.communities_users.where(user: current_user).first_or_initialize
    sub.assign_attributes(status: :expected)
    sub.save
    flash[:notice] = 'Заявка подана, ожидайте'
    render
  end

  def create_news
    @news = @resource_instance.news_items.build(news_item_params.merge(user: current_user))
    @news.save
    render
  end

  def update_news
    @news = NewsItem.find(params[:button].to_i).update(news_item_params)
    render
  end

  def render_form
    @news = NewsItem.find(params[:resource_id].to_i)
    render
  end

  def news_index
    news = @resource_instance.news_items.where(state: news_state_params)
    @news = news.order(created_at: :desc).page(params[:page]).per(params[:per_page])
    gon.news_count = news.count
    @tab = params[:state]
    render
  end

  def user_index
    @users = @resource_instance.users
    respond_with @users
  end

  def search_news_by_tag
    @news = NewsItem.tagged_with(params[:tag])
              .where(community_id: @resource_instance.id, state: news_state_params)
              .order(created_at: :desc)
    @tab = news_state_params
    render
  end

  def allowed_states
    render json: @resource_instance.news_items.find(params[:resource_id])
                                   .map{ |n| n.aasm.states(permitted: true).map{ |s| s.name.to_s } }
  end

  def change_state
    @resource_instance.send(state_params[:association]).find(params[:resource_id]).apply_state(state_params[:state])
    redirect_to :back
  end
  
  private

  def permitted_attributes
    [:name, :description, :c_type, :photo, :user_id, :tag_list, { documents: [] }]
  end

  def association_chain
    super.includes(:users).order(created_at: :desc)
  end

  def init_news
    @news = @resource_instance.news_items.build(user: current_user)
  end

  def init_notification
    @notification = @resource_instance.notifications.build(user: current_user)
  end
  
  def init_comment
    @comment = current_user.comments.build
  end

  def news_item_params
    params.require(:news_item).permit(:body, :title, :preview, :tag_list)
  end

  def news_state_params
    allowed_events = %w(#published #draft #unpublished #archived)

    params.permit(:id, :state, :tag, :page, :per_page)
    params.delete(:state) unless params[:state].in? allowed_events
    params[:state]&.sub('#', '')
  end

  def state_params
    allowed_states = %w(published draft unpublished archived accepted expected rejected excluded)
  
    params.permit(:id, :state, :subdomain, :_method, :authenticity_token, :resource_id, :association, resource_name.to_sym => {})
    params.delete(:state) unless params[:state].in? allowed_states
    params
  end
end
