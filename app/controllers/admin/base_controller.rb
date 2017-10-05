class Admin::BaseController < ApplicationController
  #include DeviseTokenAuth::Concerns::SetUserByToken
  respond_to :html

  def after_sign_in_path_for(resource)
    profiles_path(current_user)
  end

  def after_sign_out_path_for(resource)
    root_path
  end
end
