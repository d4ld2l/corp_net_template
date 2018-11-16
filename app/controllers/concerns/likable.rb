module Likable
  extend ActiveSupport::Concern
  
  included do
    append_before_action :set_resource, only: %i[show create update destroy like unlike likes]

    def like
      if @resource_instance&.already_liked?(current_account&.id)
        render json: { success: false, error: 'Вы уже оставили лайк' }
      else
        @resource_instance.likes << Like.new(account: current_account)
        @resource_instance.reload
        render json: { success: true, current_likes_count: @resource_instance.likes_count }
      end
    end

    def unlike
      l = @resource_instance.likes.where(account: current_account)&.first
      if l
        if l&.destroy
          @resource_instance.reload
          render json: { success: true, current_likes_count: @resource_instance.likes_count }
        else
          render json: { success: false, error: l&.errors }
        end
      else
        render json: { success: false, error: 'Чтобы снять лайк, его нужно сначала оставить' }
      end
    end

    def likes
      render json: @resource_instance&.likes&.as_json(include: { account: {} })
    end
  end
end
