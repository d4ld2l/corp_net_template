class Admin::Resources::ProjectsController < Admin::ResourceController

  def index
    @q = Project.ransack(params[:q])
    @collection = @q.result(distinct: true).page(params[:page]).per(30)
  end

  def destroy
      Project.find(params[:id]).destroy
      redirect_to projects_path, notice: "Проект удален"
  end

  private

  def permitted_attributes
    [:legal_unit_id, :title, :charge_code, :description, :manager, :customer_id, :begin_date, :end_date, :status,
     user_projects_attributes:[:id, :project_role_id, :user_id, :start_date, :end_date,
                               :skills_list, :duties, :feedback, :worked_hours,
                               :rating, :project_id, :_destroy]]
  end
end
