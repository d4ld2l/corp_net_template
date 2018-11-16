class Admin::Resources::RolesController < Admin::ResourceController
  include Paginatable

  def index 
    if params[:sort_by] and not params[:q]
      order_settings = params[:sort_by] + ' ' + @sort_order
      @roles = @roles.reorder(order_settings)
    end 
  end 

  private

  def permitted_attributes
    [ :name, role_permissions_attributes: [:id, :permission_id, :_destroy] ]
  end
end
