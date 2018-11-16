class Admin::BaseController < ApplicationController
  #include DeviseTokenAuth::Concerns::SetaccountByToken
  before_action :authenticate_account!
  before_action :check_account_not_blocked
  before_action :set_tenant_for_supervisor, if: :account_signed_in?
  respond_to :html

  def after_sign_in_path_for(resource)
    profiles_path(current_account)
  end

  def after_sign_out_path_for(resource)
    new_account_session_path
  end

  def check_account_not_blocked
    if current_account && current_account.blocked?
      flash[:notice] = 'Аккаунт был заблокирован, обратитесь к администратору'
      sign_out current_account
      redirect_to new_account_session_path
    end
  end

  def authenticate_account!
    if account_signed_in?
      super
    else
      redirect_to new_account_session_path, notice: 'Для совершения данного действия вам необходиом авторизоваться'
    end
  end

  def set_tenant_for_supervisor
    if current_account&.supervisor? && session[:company_id].present?
      ActsAsTenant.current_tenant = Company.find_by(id: session[:company_id])
    end
  end
end
