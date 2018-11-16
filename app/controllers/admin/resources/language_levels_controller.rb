class Admin::Resources::LanguageLevelsController < Admin::ResourceController
  include Paginatable

  private

  def permitted_attributes
    [:id, :value, :name]
  end
end
