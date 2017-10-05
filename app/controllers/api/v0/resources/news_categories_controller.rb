class Api::V0::Resources::NewsCategoriesController < Api::ResourceController
  private

  def permitted_attributes
    [:name]
  end
end
