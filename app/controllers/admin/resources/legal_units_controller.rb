class Admin::Resources::LegalUnitsController < Admin::ResourceController
  before_action :build_resource, only: [:new, :create]
  before_action :set_resource, only: [:edit, :update, :show, :destroy, :edit_employees, :update_employees]
  # before_action :set_profiles, only: [:edit_employees, :update_employees]
  before_action :set_accounts, only: [:edit_employees, :update_employees]
  #before_action :set_positions_and_departments, only: [:edit_employees, :update_employees]
  include Paginatable

  def edit_employees
    
  end

  def update_employees
    if @resource_instance.update_attributes(resource_params)
      redirect_to @resource_instance, notice: "Сущность успешно обновлена"
    else
      puts @resource_instance.errors.inspect
      render :edit_employees
    end
  end

  def destroy
    begin
      @resource_instance.destroy if @resource_instance
      redirect_to @resource_collection, notice: "Сущность успешно удалена"
    rescue
      redirect_to @resource_collection, alert: "Невозможно удалить юрлицо (есть зависимые сущности)"
    end
  end

  private

  def permitted_attributes
    [
        :id, :name, :full_name, :city, :legal_address, :assistant_id, :inn_number, :kpp_number, :ogrn_number, :general_director,
        :administrative_director, :general_accountant, :code, :uuid, :logo, legal_unit_employees_attributes:
          [:id, :account_id, :default, :email_corporate, :email_work, :structure_unit,
           :phone_corporate, :phone_work, :office, :wage, :hired_at, :wage_rate, :pay, :extrapay,
           :contract_end_at, :starts_work_at, :contract_type_id, :contract_id, :probation_period, :_destroy,
           legal_unit_employee_state_attributes:[:id, :state, :comment],
           legal_unit_employee_position_attributes: [:id, :department_code, :position_code]
          ]
    ]
  end

  def set_accounts
    a_ids = @resource_instance.legal_unit_employees.map(&:account_id)
    @accounts = Account.where.not(id: a_ids).map{|x| [x.full_name, x.id]}
  end

  def set_positions_and_departments
    @positions = Position.where(legal_unit_id:@resource_instance.legal_unit_id).map{|x| [x.name_ru, x.id]}
    @departments = Department.where(legal_unit_id:@resource_instance.legal_unit_id).map{|x| [x.name_ru, x.id]}
  end
end
