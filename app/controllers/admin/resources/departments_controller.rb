class Admin::Resources::DepartmentsController < Admin::ResourceController
  include Paginatable

  def index 
    if params[:sort_by] and not params[:q]
      @collection = @collection.includes(:legal_unit)
    end 
    super 
  end 

  def create
    if @resource_instance.save
      redirect_to @resource_instance, notice: "Подразделение успешно создано"
    else
      render :new
    end
  end

  def update
    if @resource_instance.update_attributes(resource_params)
      redirect_to @resource_instance, notice: "Подразделение успешно обновлено"
    else
      render :edit
    end
  end

  def destroy
    @resource_instance.destroy if @resource_instance
    redirect_to @resource_collection, notice: "Подразделение успешно удалено"
  end

  def import
    begin
      Department.from_csv(params.dig(:import_departments, :import_file)&.tempfile, legal_unit_id: params.dig(:import_departments,:legal_unit_id))
      redirect_to resource_class, notice: 'Данные успешно загружены'
    rescue
      redirect_to resource_class, error: 'При загрузке данных произошла ошибка'
    end
  end

  def as_csv
    if params[:legal_unit_id]
      @collection = association_chain.where(legal_unit_id: params[:legal_unit_id])
      file = Tempfile.new
      file.write @collection.to_csv(columns:[:code, :name_ru, :parent_code, :region])
      file.flush
      send_file file, filename: "departments-#{Date.today}.csv"
    else
      render nothing: true
    end
  end

  def to_mailing_list
    set_resource
    @resource_instance.to_mailing_list(current_account)
    redirect_to @resource_instance, notice: "Команда успешно создана"
  end

  private

  def permitted_attributes
    [:legal_unit_id, :company_id, :parent_id, :code, :name_ru, :region, :manager_id, :logo]
  end

  def association_chain
    super.reorder(created_at: :desc)
  end
end
