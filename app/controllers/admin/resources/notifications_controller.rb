class Admin::Resources::NotificationsController < Admin::ResourceController

  def index
    if parent_params ||= params[:resource_params]
      @notifications = parent_params[:association].singularize.classify.constantize.find(parent_params[:id]).notifications
    else
      super
    end
  end

  def show
    redirect_to @resource_instance.notice
  end
end
