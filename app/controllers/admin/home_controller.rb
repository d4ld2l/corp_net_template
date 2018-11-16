class Admin::HomeController < Admin::BaseController
  skip_before_action :authenticate_account!, only: :fallback
  skip_before_action :check_enabled

  def index
    @communities = Community.last(5)
    @news = NewsItem.only_published.last(5)
  end

  def fallback
  end

  def set_tenant
    session[:company_id] = params[:company_id]
    redirect_to root_path
  end
end
