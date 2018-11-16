class Admin::Resources::AccountsController < Admin::ResourceController
  include Paginatable

  before_action :reset_tenant, only: [:edit, :show, :update]
  before_action :init_email, only: :my
  before_action :set_resource, only: [:edit, :update, :show, :destroy, :to_active, :to_blocked]



  def show
    redirect_to [:my, :account] if @resource_instance == current_account
    super
  end

  def index
    if params[:sort_by] and not params[:q]
      case params[:sort_by]
        when 'legal_units.name'
            @collection = @collection.joins(default_legal_unit_employee: :legal_unit)
      end 
    end 
    super 
  end 

  def new
    @password_panel_name = 'Создание пароля'
    super
  end

  def edit 
    @editing = true 
    @password_panel_name = 'Редактирование пароля'
    super
  end 

  def create
    @password_panel_name = 'Создание пароля'
    super
  end   

  def import
    legal_unit_id = params.dig(:account, :import_legal_unit_id)
    begin
      imported_ids = Parsers::XLSX::AccountsXlsxParser.from_xlsx(params.dig(:account, :import_file)&.tempfile, legal_unit_id)

      # увольняем всех, кого не было в файле, но только в текущем юрлице.
      lues_ids = LegalUnitEmployee.where(legal_unit_id: legal_unit_id).where.not(account_id: imported_ids).pluck(:legal_unit_employee_state_id)
      LegalUnitEmployeeState.where(id: lues_ids).update_all(state: 'Уволен')
      redirect_to resource_class, notice: 'Данные успешно загружены'
    rescue Exception => e
      alert_message = "При импорте данных произошла ошибка"
      alert_message += ": <br> #{e.message}" if e.class.name == 'ProfileImportException'
      redirect_to resource_class, alert: alert_message.html_safe
    end
  end 

  def export
    selected_legal_unit_id = params[:legal_unit_id]
    collection = Account.includes(:all_legal_unit_employees).where(legal_unit_employees: {legal_unit_id: selected_legal_unit_id}).references('legal_unit_employees')
    file = Parsers::XLSX::AccountsXlsxParser.to_xlsx(collection, selected_legal_unit_id)
    send_file file, filename: "Пользователи #{LegalUnit.find(selected_legal_unit_id).name} #{I18n.l(Date.today)}.xlsx"
  end 

  def update 
    @password_panel_name = 'Редактирование пароля'
    if params[:account][:password] == '' and params[:account][:password_confirmation] == ''
      params[:account].delete :password
      params[:account].delete :password_confirmation
    end 
    super
  end

  def my
    @resource_instance = current_account
    reset_tenant
  end

  def edit_password
    redirect_to(
        account_path(current_account),
        notice: 'Необходимо заполнить обязательные поля профиля'
    ) unless current_account.valid?
  end

  def update_password
    if current_account.update_with_password(password_params)
      bypass_sign_in current_account
      redirect_to my_account_path, notice: 'Пароль успешно изменен'
    else
      redirect_to password_edit_path, notice: 'Ошибка при изменении пароля'
    end
  end

  def to_active
    if @resource_instance.may_to_active?
      @resource_instance.to_active!
      redirect_to accounts_path, notice: 'Пользователь разблокирован'
    else
      redirect_to accounts_path, error: 'Невозможно разблокировать пользователя'
    end
  end

  def to_blocked
    if @resource_instance.may_to_blocked?
      @resource_instance.to_blocked!
      redirect_to accounts_path, notice: 'Пользователь заблокирован'
    else
      redirect_to accounts_path, error: 'Невозможно заблокировать пользователя'
    end
  end

  def send_email
    @message = SendInvite.new(email_params)

    if account ||= Account.find_by_email(email_params[:email])
      _path = accounts_path(account)
      mess = "Пользователь с указанным адресом электронной почты уже существует #{ActionController::Base.helpers.link_to(account&.full_name, _path)}"
      redirect_to [current_account], alert: mess
    elsif @message.valid?
      AccountMailer.send_email(@message, current_account).deliver
      redirect_to [current_account], notice: 'Приглашение отправлено'
    else
      render :send_email, layout: false
    end
  end

  private

  def permitted_attributes
    [:import_file, :import_legal_unit_id, :surname, :name, :middlename, :email, :sex, :city, :photo,
     :birthday, :office_id, :skype, :kids, :marital_status,
     :current_password, :password, :password_confirmation, :email, :login, :status, role_ids:[], social_urls: [],
     default_legal_unit_employee_attributes: [:id, :legal_unit_id, :hired_at, :contract_end_at, :contract_type_id, :structure_unit,
                                              :office_id, :manager_id, :email_work, :email_corporate, :phone_work, :phone_corporate,
                                              legal_unit_employee_position_attributes: [:id, :department_code, :position_code],
                                              legal_unit_employee_state_attributes: [:id, :state]
     ],
     resumes_attributes: [:id, :account_id, :candidate_id, :first_name, :middle_name,
                          :last_name, :city, :phone, :email, :skype,
                          :preferred_contact_type, :birthdate, :photo, :remote_photo_url, :sex,
                          :martial_condition, :have_children, :skills_description, :specialization,
                          :desired_position, :salary_level, :comment, :documents,
                          :professional_specialization_id, :resume_source_id, :_destroy,
                          skill_list: [], experience: [], employment_type: [],
                          working_schedule: [], additional_contacts_attributes: [:id, :type, :link],
                          language_skills_attributes: [:language_id, :language_level_id, language_attributes: [:name]],
                          resume_documents_attributes: [:id, :file, :name, :_destroy],
                          resume_work_experiences_attributes: [:id, :position, :company_name,
                                                               :region, :website, :start_date,
                                                               :end_date, :experience_description],
                          resume_recommendations_attributes: [:id, :recommender_name, :company_and_position,
                                                              :phone, :email, :_destroy],
                          resume_educations_attributes: [:id, :education_level_id, :school_name,
                                                         :faculty_name, :speciality, :end_year, :_destroy],
                          resume_qualifications_attributes: [:id, :name, :company_name,
                                                             :speciality, :end_year, :file, :_destroy],
                          resume_courses_attributes: [:id, :name, :company_name, :end_year, :file, :_destroy],
     ],
     account_phones_attributes: [:id, :kind, :number, :preferable, :whatsapp, :telegram, :viber, :account_id, :_destroy],
     account_emails_attributes: [:id, :kind, :email, :preferable, :account_id, :_destroy],
     account_messengers_attributes: [:id, :name, :account_id, :_destroy, phones: []]
    ]
  end

  def quick_search
    query = params[:q]&.dup.to_s[0..127]

    reserved_symbols = %w(+ - = && || > < ! ( ) { } [ ] ^ " ~ * ? : \\ /)

    reserved_symbols.each do |s|
      query.gsub!(s, "\\#{s}")
    end

    #TODO: filter by legal_unit in ES

    @quick_search ||= association_chain.__elasticsearch__.search("*#{query}*", size: 1000)
    @quick_search.records
  end

  def init_email
    @message = SendInvite.new
  end

  def email_params
    params.require(:send_invite).permit(:email, :surname, :name, :middle_name)
  end

  def association_chain
    if params[:status] == 'active'
      super.not_blocked
    elsif params[:status] == 'blocked'
      super.blocked
    else
      super
    end
  end

  def reset_tenant
    if current_account&.id&.to_s == params[:id] || controller_name == 'accounts' && action_name == 'my'
      set_current_tenant(current_account.company)
    end
  end

  def password_params
    params.require(:account).permit(:password, :password_confirmation, :current_password)
  end
end
