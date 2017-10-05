class Api::V0::HomeController < Api::BaseController
  def index
    render json: {'api version': 0.1}
  end
end
