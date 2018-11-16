class Api::V0::Resources::DiscussionCommentsController < Api::V0::Resources::CommentsController
  def index
    render json:
             { comments: @collection.as_json(json_collection_inclusion),
               current_page: page }
  end

  def create
    can_comment = @resource_instance&.commentable&.discussers&.exists?(account_id: current_account.id) &&
      @resource_instance&.commentable&.opened?
    unless can_comment
      return render json: { success: false, errors: ['Нельзя комментировать данную сущность'] }
    end
    if @resource_instance.save
      render json: { success: true, comment: @resource_instance.as_json(json_resource_inclusion) }
    else
      render json: { success: false, errors: @resource_instance.errors }
    end
  end

  def update
    can_update = @resource_instance&.can_edit?(current_account.id)
    unless can_update
      return render json: { success: false, errors: ['Вы не можете редактировать данный комментарий'] }
    end
    if @resource_instance.deleted_at
      return render json: { success: false, errors: ['Вы не можете редактировать удаленный комментарий'] }
    end
    if @resource_instance.update_attributes(resource_params)
      render json: { success: true, comment: @resource_instance.as_json(json_resource_inclusion) }
    else
      render json: { success: false, errors: @resource_instance.errors }
    end
  end

  def delete
    can_destroy = @resource_instance&.can_edit?(current_account.id)
    unless can_destroy
      return render json: { success: false, errors: ['Вы не можете удалить данный комментарий'] }
    end
    if @resource_instance.deleted_at
      return render json: { success: false, errors: ['Вы не можете удалить удаленный комментарий'] }
    end
    if @resource_instance.safe_delete(current_account.id)
      render json: { success: true, comment: @resource_instance.as_json(json_resource_inclusion) }
    else
      render json: { success: false, errors: @resource_instance.errors }
    end
  end

  def collection_name
    'comments'
  end

  def resource_class(variable = nil)
    if variable
      super variable
    else
      Comment
    end
  end

  def association_chain
    resource_collection.includes(chain_collection_inclusion).where(commentable).reorder(created_at: :asc).page(page).per(per_page)
  end

  def json_collection_inclusion
    @json_collection_inclusion ||= { methods: [:likes_count],
                                     except: %i[user_id commentable_type commentable_id],
                                     current_account_id: current_account.id,
                                     include: {
                                       account: { methods: :full_name }, likes: {}, photos: {}, documents: {}
                                     } }
  end

  def json_resource_inclusion
    @json_resource_inclusion ||= { methods: [:likes_count],
                                   except: %i[user_id commentable_type commentable_id],
                                   current_account_id: current_account.id,
                                   include: {
                                     account: { methods: :full_name }, likes: {}, photos: {}, documents: {}
                                   } }
  end

  def chain_collection_inclusion
    @chain_collection_inclusion ||= %i[photos documents account likes]
  end

  def chain_resource_inclusion
    @chain_resource_inclusion ||= %i[photos documents account likes]
  end

  def page
    params[:last] == 'true' ? commentable_resource.last_comments_page(per_page) : params[:page] || commentable_resource.page_of_last_read(current_account.id, per_page)
  end

  def permitted_attributes
    [:id, :body, :parent_comment_id,
     photos_attributes: %i[id name file _destroy],
     documents_attributes: %i[id name file _destroy]]
  end
end
