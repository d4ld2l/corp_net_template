class Admin::Resources::CompaniesController < Admin::ResourceController
  include Paginatable

  def create
    if @resource_instance.save && @resource_instance.errors.empty?
      flash[:seeds] = @resource_instance.seeds
      redirect_to @resource_instance, notice: "Сущность успешно создана"
    else
      render :new
    end
  end

  def make_default
    c = Company.find(params[:id])
    c.make_default if c
    redirect_to companies_path, notice: 'Тенант по-умолчанию успшно обновлен'
  end

  private

  def permitted_attributes
    [:name, :subdomain, :domain]
  end
end
