class Api::V0::HomeController < Api::BaseController
  skip_before_action :check_account_not_blocked
  skip_before_action :check_enabled

  def index
    render json: {'api version': 0.7}
  end
end
