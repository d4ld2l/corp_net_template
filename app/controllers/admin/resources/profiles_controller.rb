class Admin::Resources::ProfilesController < Admin::ResourceController
  before_action :init_email, only: :my

  def show
    redirect_to [:my, :profile] if @resource_instance == current_profile
    super
  end

  def new
    if params[:user_id]
      user = User.find(params[:user_id])
    else
      user = current_user
    end
    @resource_instance.user = user
    super
  end

  def my
    @resource_instance = current_profile
  end

  def send_email
    @message = SendInvite.new(email_params)

    if user ||= User.find_by_email(email_params[:email])
      _path = user&.profile ? profile_path(user.profile) : users_admin_path(user)
      mess = "Пользователь с указанным адресом электронной почты уже существует #{ActionController::Base.helpers.link_to(user.profile&.full_name, _path)}"
      redirect_to [current_profile], alert: mess
    elsif @message.valid?
      UserMailer.send_email(@message, current_user).deliver
      redirect_to [current_profile], notice: 'Приглашение отправлено'
    else
      render :send_email, layout: false
    end
  end

  private

  def permitted_attributes
    [:surname, :name, :middlename, :email, :sex, :city, :photo,
     :birthday, :position, :email_work, :email_private,
     :phone_number_landline, :phone_number_corporate,
     :phone_number_private, :office_id, :skype, :telegram,
     :vk_url, :fb_url, :linkedin_url, :position_code,
     :department_code, :department_head, :manager_id,
     default_legal_unit_employee_attributes:[:id, :legal_unit_id,
       :office_id, :manager_id, :email_work, :email_corporate, :phone_work, :phone_corporate,
       legal_unit_employee_position_attributes:[:id, :department_code, :position_code],
       legal_unit_employee_state_attributes:[:id, :state]
     ]
    ]
  end

  def init_email
    @message = SendInvite.new
  end

  def email_params
    params.require(:send_invite).permit(:email, :surname, :name, :middle_name)
  end
end
