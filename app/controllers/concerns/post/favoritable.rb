module Post::Favoritable
  extend ActiveSupport::Concern

  included do
    def to_favorites
      post_id = Post.where(id: params[:id]).present? ? params[:id] : nil
      fav = FavoritePost.find_or_initialize_by(account_id: current_account.id, post_id: post_id)
      if post_id.present? && !fav.persisted? && fav.save
        render json: { success: true }
      else
        render json: { success: false, errors: fav&.errors || ['Невозможно добавить в избранное'] }
      end
    end

    def from_favorites
      post_id = Post.where(id: params[:id]).present? ? params[:id] : nil
      fav = FavoritePost.find_by(account_id: current_account.id, post_id: params[:id])
      if post_id.present? && fav.present? && fav.destroy!
        render json: { success: true }
      else
        render json: { success: false, errors: fav&.errors || ['Невозможно удалить из избранного'] }
      end
    end
  end
end
