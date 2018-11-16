class Admin::Resources::AchievementGroupsController < Admin::ResourceController
  include Paginatable

  private

  def permitted_attributes
    [:id, :name]
  end
end
