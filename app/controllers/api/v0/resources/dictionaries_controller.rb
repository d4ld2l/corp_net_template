class Api::V0::Resources::DictionariesController < Api::ResourceController

  private

  DICTIONARIES = %w(news_category tag contract_type event_type)

  def collection_name
    if DICTIONARIES.include?(params[:dictionary_name])
      @collection_name ||= params[:dictionary_name]
    else
      raise ActionController::RoutingError.new('Not Found')
    end
  end

  def association_chain
    if params[:dictionary_name] == 'tag'
      ActsAsTaggableOn::Tag.all.where('taggings_count > 0')
    else
      resource_collection.all
    end
  end

  def permitted_attributes
    [:name]
  end
end
