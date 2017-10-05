class Admin::Resources::NewsItemsController < Admin::ResourceController
  include Publishable
  include Commentable
  include Paginatable

  private

  def permitted_attributes
    super + [:news_category, :tag_list, photos_attributes:[:id, :_destroy, :file, :name]]
  end

  def association_chain
    super.order(created_at: :desc)
  end
end
