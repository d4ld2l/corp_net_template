class Api::V0::Resources::PermissionsController < Api::ResourceController

  def my
    @collection = current_account&.permissions.distinct
    render json: @collection.as_json
  end

end
