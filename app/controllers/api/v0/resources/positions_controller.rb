class Api::V0::Resources::PositionsController < Api::ResourceController
  before_action :authenticate_user!

  private

  def permitted_attributes
    [:code, :name_ru, :description, :position_group_code, :salary_from, :salary_up]
  end
end
