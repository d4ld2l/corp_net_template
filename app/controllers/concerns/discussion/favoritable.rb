module Discussion::Favoritable
  extend ActiveSupport::Concern

  included do
    def to_favorites
      Discusser.where(account_id: current_account&.id, discussion_id: @several_resource.map(&:id)).update_all(faved: true)
      render json: { success: true, favorites_count: resource_collection.favorites(current_account&.id).count }
    end

    def from_favorites
      Discusser.where(account_id: current_account&.id, discussion_id: @several_resource.map(&:id)).update_all(faved: false)
      render json: { success: true, favorites_count: resource_collection.favorites(current_account&.id).count }
    end
  end
end
