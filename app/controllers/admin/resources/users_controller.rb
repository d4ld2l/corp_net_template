class Admin::Resources::UsersController < Admin::ResourceController
  include Autocompletable
  include Paginatable

  def index
    gon.controller_name = 'users_admin'
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
      redirect_to users_admin_index_path, notice: "Сущность успешно создана"
    else
      render :new
    end
  end

  def confirm_import
    require 'parsers/xlsx/users_from_1c_parser'
    @file = params.dig(:uploaded_file, :file)&.tempfile
    # begin
    @parsed_users = Parsers::XLSX::UsersFrom1CParser.parse(@file,
                                                               company_domain:params[:uploaded_file][:company_domain],
                                                               legal_unit_id: params[:uploaded_file][:legal_unit_id])
    # rescue
    #   flash[:alert] = "Неверный формат файла. Пожалуйста, загрузите корректный файл."
    #   redirect_to users_admin_index_path
    # end
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
    redirect_to users_admin_index_path
  end

  def update
    if @resource_instance.update_attributes(resource_params.merge(tokens: {}))
      redirect_to root_path, notice: "Сущность успешно обновлена"
    else
      render :edit
    end
  end
  
  private

  def permitted_attributes
    [:email, :password, :password_confirmation, :role_id, :legal_unit_id,
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
    super.order(created_at: :desc).only_with_profile.not_admins#.where('sign_in_count > 0')
  end
end
