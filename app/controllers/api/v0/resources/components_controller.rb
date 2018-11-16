class Api::V0::Resources::ComponentsController < Api::BaseController
  def index
    render json: @collection.as_json
  end
end
