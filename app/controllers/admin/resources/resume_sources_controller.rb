class Admin::Resources::ResumeSourcesController < Admin::ResourceController
  include Paginatable

  private

  def permitted_attributes
    [:id, :name]
  end
end
