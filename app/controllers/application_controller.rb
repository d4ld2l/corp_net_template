class ApplicationController < ActionController::Base
  # include DeviseTokenAuth::Concerns::SetUserByToken
  protect_from_forgery with: :null_session #:exception
  set_current_tenant_through_filter
  skip_before_action :track_ahoy_visit
  before_action :set_tenant_by_current_account
  before_action :track_current_account_and_host
  around_action :set_current_account_timezone
  append_after_action :track_ahoy_visit
  alias_method :current_user, :current_account
  include Componentable


  rescue_from ActsAsTenant::Errors::NoTenantSet do |e|
    respond_to do |format|
      format.html { redirect_to fallback_path, notice: 'Тенант не определен' }
      format.json { render json: { success: false, error: 'Тенант не определен', status: 404 } }
    end
  end

  protected

  def set_tenant_by_host
    host = params[:host] || request.headers["X-Reactor-Host"]
    # delete schema & path
    if host
      if stripped_host = URI.parse(host).host
        host = stripped_host
      end

      # split into domain & subdomain
      splitted_host = host.split('.')
      domain = splitted_host[1..-1].join('.')
      subdomain = splitted_host[0]

      #set company & tenant
      company = Company.find_by(subdomain: subdomain, domain: domain)
      company = Company.find_by(subdomain: subdomain) unless company
      #company = Company.default unless company
      raise ActsAsTenant::Errors::NoTenantSet unless company
      set_current_tenant(company)
    else
      raise ActsAsTenant::Errors::NoTenantSet
    end
  end

  def set_tenant_by_current_account
    if current_account
      set_current_tenant(current_account&.company)
    else
      set_current_tenant(Company.default)
    end
  end

  def track_current_account_and_host
    RequestStore.store[:current_account] ||= current_account
    RequestStore.store[:current_host] = request.protocol + request.host_with_port
  end

  def set_current_account_timezone(&block)
    time_zone = current_account.try(:time_zone) || 'Moscow'
    Time.use_zone(time_zone, &block)
  end
end
