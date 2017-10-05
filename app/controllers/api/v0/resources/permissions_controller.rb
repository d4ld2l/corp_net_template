class Api::V0::Resources::PermissionsController < Api::ResourceController
  before_action :authenticate_user!
  include ActionController::ImplicitRender

  def my
    @collection = current_user&.role&.permissions
    render json: @collection.as_json
  end

end
