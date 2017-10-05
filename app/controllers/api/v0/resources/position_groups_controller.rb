class Api::V0::Resources::PositionGroupsController < Api::ResourceController
  before_action :authenticate_user!

  private

  def permitted_attributes
    [:code, :name_ru, :description]
  end
end
