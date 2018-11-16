class Admin::Resources::ComponentsController < Admin::ResourceController
  before_action :set_resource, only: [:edit, :update, :show, :destroy, :toggle]

  def show
    redirect_to components_path
  end

  def new
    redirect_to components_path, alert: 'Нельзя создать настройку включения модуля'
  end

  def toggle
    if @resource_instance.toggle
      redirect_to components_path, notice: 'Успешно обновлено'
    else
      redirect_to components_path, alert: 'Невозможно обновить настройку'
    end
  end

  private

  def association_chain
    super.includes(:core_component).reorder(core_component_id: :desc, name: :asc)
  end

  def permitted_attributes
    [:id, :enabled]
  end
end
