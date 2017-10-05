class Api::V0::Resources::CommunitiesController < Api::ResourceController

  def index
    render json: @collection.as_json(methods: [:users_count], include:{news_items:{}, topics:{include:{messages:{}}}, notifications:{}, tags:{}})
  end

  def show
    render json: @resource.as_json(methods: [:users_count], include:{news_items:{}, topics:{include:{messages:{}}}, notifications:{}, tags:{}})
  end

  private

  def permitted_attributes
    [:id]
  end
end
