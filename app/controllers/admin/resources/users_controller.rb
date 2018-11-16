class Admin::Resources::UsersController < Admin::ResourceController
  include Autocompletable
  include Paginatable
  respond_to :html, :json

  before_action :set_resource, only: [:edit, :update, :show, :destroy, :to_active, :to_blocked]

  def index
    gon.controller_name = 'account'
  end
  
  def autocomplete
    render json: association_chain.search(params[:q], page: params[:page], per_page: 20, limit: 10)
                 .map { |user| user.profile.as_json(only: :id)&.merge(
                     { photo: {url: user.profile&.photo&.thumb&.url}, email: user.email }
                 ) || user.as_json(only: [:id, :email]).merge(
                     photo: { url: user.profile&.photo&.thumb&.url || ActionController::Base.helpers.asset_path('thumb_missing.png') }
                 )}
  end

  def create
    if @resource_instance.save
      redirect_to accounts_path, notice: "Сущность успешно создана"
    else
      render :new
    end
  end

  def edit
    @update_type = params[:update]
    session[:referer] = request.referer
    respond_with @resource_instance
  end

  def create_from_imported
    users_hash = params[:parsed_users]
    @parsed_users = []
    users_hash.each do |key, user_hash|
      user_hash = user_hash.permit(permitted_attributes)
      user = User.find_or_initialize_by(email: user_hash[:email])
      if user.profile.present?
        user_hash[:profile_attributes][:id] = user.profile.id
        if user.profile.default_legal_unit_employee.present?
          user_hash[:profile_attributes][:default_legal_unit_employee_attributes][:id] = user.profile.default_legal_unit_employee.id
        end
      end
      user.update_attributes!(user_hash)
      @parsed_users << user
    end
    redirect_to account_path
  end

  def to_active
    if @resource_instance.may_to_active?
      @resource_instance.to_active!
      redirect_to account_path, notice: 'Пользователь разблокирован'
    else
      redirect_to account_path, error: 'Невозможно разблокировать пользователя'
    end
  end

  def to_blocked
    if @resource_instance.may_to_blocked?
      @resource_instance.to_blocked!
      redirect_to account_path, notice: 'Пользователь заблокирован'
    else
      redirect_to account_path, error: 'Невозможно заблокировать пользователя'
    end
  end

  def update
    if @resource_instance.update_attributes(resource_params)
      redirect_to profile_path(id: @resource_instance.profile.id), notice: "Пароль успешно обновлён"
    else
      @update_type = 'password'
      render :edit
    end
  end

  def destroy
    @resource_instance.destroy if @resource_instance
    redirect_to account_path, notice: "Сущность успешно удалена"
  end

  def show_user_position
    position_name = User.find(params[:id]).profile&.position_name
    render json: { position_name: position_name }.as_json, layout: false
  end

  private

  def permitted_attributes
    [:email, :login, :password, :password_confirmation, :legal_unit_id, role_ids:[],
     profile_attributes:
         [:name, :surname, :middlename, :birthday, :department_code, :position_code, :city,
          default_legal_unit_employee_attributes:
              [:id, :legal_unit_id, :hired_at, :employee_number, :employee_uid, :individual_employee_uid,
               legal_unit_employee_position_attributes: [:position_code, :department_code]
              ]
         ]
    ]
  end

  def association_chain
    result = super.reorder(created_at: :desc)
    if params[:status]
      result = result.where(status: params[:status])
    end
    result
  end
end
