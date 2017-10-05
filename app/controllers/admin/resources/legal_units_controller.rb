class Admin::Resources::LegalUnitsController < Admin::ResourceController
  before_action :build_resource, only: [:new, :create]
  before_action :set_resource, only: [:edit, :update, :show, :destroy, :edit_employees, :update_employees]
  before_action :set_profiles, only: [:edit_employees, :update_employees]
  #before_action :set_positions_and_departments, only: [:edit_employees, :update_employees]
  include Paginatable

  def edit_employees; end

  def update_employees
    if @resource_instance.update_attributes(resource_params)
      redirect_to @resource_instance, notice: "Сущность успешно обновлена"
    else
      puts @resource_instance.errors.inspect
      render :edit_employees
    end
  end

  private

  def permitted_attributes
    [
        :id, :name, :code, :uuid, :logo, legal_unit_employees_attributes:
          [:id, :profile_id, :default, :email_corporate, :email_work,
           :phone_corporate, :phone_work, :office, :wage, :hired_at, :wage_rate, :pay, :extrapay,
           :contract_end_at, :starts_work_at, :contract_type_id, :contract_id, :probation_period, :_destroy,
           legal_unit_employee_state_attributes:[:id, :state, :comment],
           legal_unit_employee_position_attributes: [:id, :department_code, :position_code]
          ]
    ]
  end

  def set_profiles
    p_ids = @resource_instance.legal_unit_employees.map(&:profile_id)
    @profiles = Profile.where.not(id:p_ids).map{|x| [x.full_name, x.id]}
  end

  def set_positions_and_departments
    @positions = Position.where(legal_unit_id:@resource_instance.legal_unit_id).map{|x| [x.name_ru, x.id]}
    @departments = Department.where(legal_unit_id:@resource_instance.legal_unit_id).map{|x| [x.name_ru, x.id]}
  end
end
