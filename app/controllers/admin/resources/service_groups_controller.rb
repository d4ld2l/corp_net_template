class Admin::Resources::ServiceGroupsController < Admin::ResourceController
  def index
    @collection = @collection.page(params[:page]).per(10)
  end
end
