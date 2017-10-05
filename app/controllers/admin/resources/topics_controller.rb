class Admin::Resources::TopicsController < Admin::ResourceController
  before_action :init_community
  before_action :init_message, only: [:show, :create_message]
  before_action :set_resource, only: [:edit, :update, :show, :destroy, :create_message]
  include Paginatable

  def new
    @resource_instance = @community.topics.build
    respond_with @resource_instance
  end

  def create
    @resource_instance = @community.topics.build(resource_params)
    if @resource_instance.save
      redirect_to [@community, :topics], notice: "Сущность успешно создана"
    else
      render :new
    end
  end

  def create_message
    @message.assign_attributes(message_params)

    if @message.save
      render :add_message_to_list, message: @message, layout: false
    else
      render :create_message, layout: false
    end
  end

  private

  def init_community
    @community = Community.find(params[:community_id])
  end

  def init_message
    @message = resource_class.find(params[:id]).messages.build(user: current_user)
  end

  def association_chain
    super.order(created_at: :desc)
  end

  def message_params
    params.require(:message).permit(:body, :parent_message_id)
  end
end
