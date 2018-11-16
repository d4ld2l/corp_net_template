module Post::Commentable
  extend ActiveSupport::Concern

  def comments
    render json: @resource_instance.comments.as_json(include: { profile:{} })
  end

  def comment
    comment = Comment.new(params[:comment])
    comment.author = current_user&.profile
    if comment.valid? && @resource_instance.allow_commenting && comment.save
       render json: { success: true, comment_id: comment.id }
    else
       render json: { success: false, errors: comment.errors }
    end
  end

  def edit_comment

  end

  def delete_comment
    comment.deleted_at = DateTime.now
  end

  private

  def comment_params
    params.require(:comment).permit(:body, :parent_comment_id)
  end
end
