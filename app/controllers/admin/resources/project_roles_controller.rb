class Admin::Resources::ProjectRolesController < Admin::ResourceController
  include Paginatable

  private

  def permitted_attributes
    [:name]
  end
end
