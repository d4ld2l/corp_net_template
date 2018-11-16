class Admin::Resources::ProjectsController < Admin::ResourceController

  def index
    if params[:sort_by] and not params[:q]
      @collection = case params[:sort_by]
                    when 'count_customers'
                      @collection
                        .left_joins(:customer_projects)
                        .group(:id)
                        .reorder("COUNT(customer_projects.id) #{@sort_order}")
                    when 'legal_unit_name'
                      @collection
                        .includes(:legal_unit)
                        .group(:id)
                        .reorder("legal_units.name #{@sort_order}").group('legal_units.id')
                    else
                      order_settings = params[:sort_by] + ' ' + @sort_order
                      @collection.reorder(order_settings)
                    end
    else
      @collection = @collection.reorder(:title).page(params[:page]).per(30)
    end
  end

  def destroy
    Project.find(params[:id]).destroy
    redirect_to projects_path, notice: "Проект удален"
  end

  def to_mailing_list
    set_resource
    @resource_instance.to_mailing_list(current_account)
    redirect_to @resource_instance, notice: "Команда успешно создана"
  end

  private

  def search
    @blank_stripped_params = params.to_unsafe_h.strip_blanks
    results = resource_class.search(@blank_stripped_params.dig("q", "q"), @blank_stripped_params&.dig("q"))
    @search_count = results.results.total
    results.per(1000).records
  end

  def permitted_attributes
    [:legal_unit_id, :title, :charge_code, :description, :manager_id, :begin_date, :end_date, :status, :department_id,
     :technology_list, :methodology_list, :product_list,
     profile_projects_attributes: [
       :id, :status, :profile_id, :feedback, :worked_hours,
       :rating, :project_id, :_destroy, project_work_periods_attributes: [
       :id, :begin_date, :end_date, :role, :duties, :_destroy
     ]
     ],
     customer_projects_attributes: [:id, :customer_id, :_destroy]]
  end

  def set_collection
    @collection ||= params[:q].present? ? search : association_chain
  end
end
