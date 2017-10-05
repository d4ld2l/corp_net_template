class Api::V0::Resources::ProjectsController < Api::ResourceController
  before_action :authenticate_user!
  
  def index
    @q = Project.ransack(params[:q])
    @collection = @q.result(distinct: true)
    super
  end

  private

  def permitted_attributes
    [:title, :description, :manager, :customer_id, :begin_date, :end_date, :status]
  end
end
