class Admin::Resources::RolesController < Admin::ResourceController
  include Paginatable

  private

  def permitted_attributes
    [ :name, role_permissions_attributes: [:id, :permission_id, :_destroy] ]
  end
end
