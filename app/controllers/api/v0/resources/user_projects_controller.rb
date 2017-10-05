class Api::V0::Resources::UserProjectsController < Api::ResourceController
  before_action :authenticate_user!

  private

  def permitted_attributes
    [:user_id, :project_id]
  end
end
