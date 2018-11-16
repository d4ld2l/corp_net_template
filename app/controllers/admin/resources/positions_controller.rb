class Admin::Resources::PositionsController < Admin::ResourceController
  include Paginatable

  def create
    if @resource_instance.save
      redirect_to @resource_instance, notice: "Должность успешно создана"
    else
      render :new
    end
  end

  def update
    if @resource_instance.update_attributes(resource_params)
      redirect_to @resource_instance, notice: "Должность успешно обновлена"
    else
      render :edit
    end
  end

  def destroy
    @resource_instance.destroy if @resource_instance
    redirect_to @resource_collection, notice: "Должность успешно удалена"
  end

  private

  def permitted_attributes
    [:legal_unit_id, :code, :name_ru, :description, :position_group_code, :salary_from, :salary_up]
  end

  def association_chain
    super.reorder(created_at: :desc)
  end
end
