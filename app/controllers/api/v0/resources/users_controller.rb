class Api::V0::Resources::UsersController < Api::ResourceController
  include ActionController::ImplicitRender

  before_action :authenticate_account!, except: [:generate_new_password_email, :reset_password]

  def index
    render :index, as: :json, layout: false
  end

  def show
    render json: @resource_instance.as_json(include: [profile: [:default_legal_unit_employee]])
  end

  def update_password
    @user = current_account
    if @user.update_with_password(password_params)
      bypass_sign_in(@user)
      @user.tokens.delete_if { |k, _| k != request.headers['client'] }
      @user.save!
      ResetPasswordMailer.password_changed_email(@user.id).deliver_later
      render json: { success: true, message: 'Пароль обновлен успешно' }
    else
      render json: { success: false, errors: @user.errors.as_json }
    end
  end

  def generate_new_password_email
    @user = User.find_by(email: params[:email]&.downcase)
    if @user.present?
      @user.send(:set_reset_password_token)
      ResetPasswordMailer.send_email(@user.id).deliver_later
      render json: { success: true, message: 'Письмо с дальнейшими инструкциями было выслано на почту' }
    else
      render json: { success: false, message: 'Пользователя с таким e-mail не существует' }
    end
  end

  def reset_password
    @user = User.find_by(reset_password_token: params[:reset_password_token])
    if @user.present?
      if @user.reset_password_period_valid?
        if @user.reset_password(params[:password], params[:password_confirmation])
          @user.tokens.clear
          @user.save!
          ResetPasswordMailer.password_changed_email(@user.id).deliver_later
          render json: { success: true, message: 'Пароль обновлен успешно' }
        else
          render json: { success: false, errors: @user.errors.as_json }
        end
      else
        render json: { success: false, message: 'Истек срок действия ссылки' }
      end
    else
      render json: { success: false, message: 'Истек срок действия ссылки или она уже использовалась для восстановления пароля' }
    end
  end

  def get_ticket
    token = Devise.friendly_token(15)
    profile_id = Profile.find_by(user_id: current_user&.id)&.id
    unless profile_id.present?
      render json: { success: false, message: 'Профиль не найден' }
      return
    end
    response.headers['X-WS-TICKET'] = token
    TicketSenderWorker.perform_async(token, profile_id)
    render json: { success: true }
  end

  private

  def association_chain
    result = resource_collection.default_order.not_blocked.only_with_profile.includes(profile: [:profile_emails, :preferred_email, :profile_phones, :preferred_phone, default_legal_unit_employee: [position: [:position, :department]]], role_users: [role: [role_permissions: [:permission]]])
    if params[:role]
      result = result.where(role_users: { role_id: role_scope })
    end
    if params[:permission]
      result = result.where("permissions.name = ?", params[:permission])
    end
    result
  end

  def role_scope
    Role.where(name: params[:role]).first&.id
  end

  def permitted_attributes
    [:email, :password, :password_confirmation, :role_id]
  end

  def password_params
    params.require(:user).permit(:password, :password_confirmation, :current_password)
  end

end
