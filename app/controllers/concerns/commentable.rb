module Commentable
  extend ActiveSupport::Concern

  def add_comment
    comment_hash = comment_params
    @resource_instance = resource_class.find(params[:id])
    if comment_hash && @resource_instance
      comment_hash[:user_id] = current_user.id
      comment_hash[:parent_comment_id] = comment_params[:parent_comment_id]
      comment = Comment.new(comment_hash)
      comment.commentable_id = @resource_instance.id
      comment.commentable_type = @resource_instance.class.to_s
      if comment.save
        render json: { success: true }
      else
        render json: { success: false, errors: comment.errors }
      end
    else
      render json: { success: false }
    end
  end

  private

  def comment_params
    params.require(:comment).permit(:body, :parent_comment_id)
  end
end
