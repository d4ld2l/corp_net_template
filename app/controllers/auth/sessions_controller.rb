class Auth::SessionsController < Devise::SessionsController
  respond_to :html, :json, :js

  def create
    user_pass = params[:user][:password]
    self.resource = warden.authenticate(auth_options)
    if resource && resource.active_for_authentication?
      sign_in(resource_name, resource)
      return render :json => {:success => true}
    else
      return render :json => {:success => false}
    end
  end

  def create_from_email_message
    user = User.find_by_email(params[:email])
    client_id = params['client']
    token = params['token']
    
    if user&.valid_token?(token, client_id)
      bypass_sign_in user, scope: :user
      message = "Смените, пожалуйста, пароль пройдя по #{ActionController::Base.helpers.link_to 'ссылке', edit_users_admin_url(user)}".html_safe
      redirect_to users_admin_index_url, notice: message
    else
      redirect_to root_url
    end
  end

  protected

  def after_update_path_for(resource)
    new_user_session_path
  end
end