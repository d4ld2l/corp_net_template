class Admin::Resources::PermissionsController < Admin::ResourceController
  include Paginatable

  private

  def permitted_attributes
    [:name, :description, :code]
  end
end
