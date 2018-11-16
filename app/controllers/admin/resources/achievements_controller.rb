class Admin::Resources::AchievementsController < Admin::ResourceController
  include Paginatable

  private

  def permitted_attributes
    [:id, :name, :code, :achievement_group_id, :can_achieve_again, :enabled, :pay, :photo]
  end
end
