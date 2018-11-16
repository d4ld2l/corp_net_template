class Auth::SessionsController < Devise::SessionsController
  respond_to :html, :json, :js
  skip_before_action :check_enabled
  skip_before_action :set_tenant_by_current_account
  skip_before_action :track_current_account_and_host
  skip_around_action :set_current_account_timezone
  before_action :set_tenant_by_subdomain, only: :create

  def new
    render :new, content_type: 'text/html'
  end

  def create
    #self.resource = warden.authenticate!(auth_options)
    resource = resource_class.where(["lower(login) LIKE ? OR lower(email) LIKE ?", resource_params[:email], resource_params[:email]]).first
    valid_password = resource&.valid_password?(resource_params[:password])
    if resource && valid_password && resource&.company_id == current_tenant&.id
      sign_in(resource_name, resource)
      return render :json => {:success => true}
    else
      return render :json => {:success => false}
    end
  end

  def create_from_email_message
    user = Account.find_by_email(params[:email])
    client_id = params['client']
    token = params['token']
    
    if user&.valid_token?(token, client_id)
      bypass_sign_in user, scope: :user
      message = "Смените, пожалуйста, пароль пройдя по #{ActionController::Base.helpers.link_to 'ссылке', edit_account_url(user)}".html_safe
      redirect_to accounts_url, notice: message
    else
      redirect_to root_url
    end
  end

  protected

  def after_update_path_for(resource)
    new_account_session_path
  end

  def after_create_path_for(resource)
    new_account_session_path
  end

  private

  def set_tenant_by_subdomain
    subdomain = params.dig(:account, :subdomain)
    if subdomain&.present?
      t = Company.find_by(subdomain: subdomain)
      render :json => {:success => false} unless t
    else
      t = Company.default
    end
    set_current_tenant(t)
  end

  def rocket_chat_authorize(user_pass)
    res = current_user.rocket_chat_authorize(current_user.email, user_pass)
    session[:rocket_chat_client_id] = res[:client_id]
    session[:rocket_chat_token] = res[:token]
  end
end