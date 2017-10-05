class Api::V0::Resources::RolesController < Api::ResourceController
  before_action :authenticate_user!

  private

  def permitted_attributes
    [:name]
  end
end
