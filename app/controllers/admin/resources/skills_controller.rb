class Admin::Resources::SkillsController < Admin::ResourceController
  include Paginatable

  private

  def permitted_attributes
    [:name]
  end
end
