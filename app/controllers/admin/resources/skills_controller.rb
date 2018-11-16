class Admin::Resources::SkillsController < Admin::ResourceController
  include Paginatable

  private

  def association_chain
    resource_collection.all.includes(chain_collection_inclusion).order(indicators_count: :desc)
  end

  def chain_collection_inclusion
    [:indicators]
  end

  def permitted_attributes
    [:name, :description, indicators_attributes:[:id, :name, :_destroy]]
  end
end
