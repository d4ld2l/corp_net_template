class Auth::RegistrationsController < Devise::RegistrationsController
  skip_before_action :check_enabled, only: [:create, :sign_up]

  def create
    build_resource(sign_up_params)

    if resource.save
      if resource.active_for_authentication?
        set_flash_message :notice, :signed_up if is_navigational_format?
        sign_up(resource_name, resource)
        return render :json => {:success => true}
      else
        set_flash_message :notice, :"signed_up_but_#{resource.inactive_message}" if is_navigational_format?
        expire_session_data_after_sign_in!
        return render :json => {:success => true}
      end
    else
      clean_up_passwords resource
      return render :json => {:success => false, :errors => resource.errors}
    end
  end

  def sign_up(resource_name, resource)
    sign_in(resource_name, resource)
  end

  protected

  def after_update_path_for(resource)
    new_user_session_path
  end
end