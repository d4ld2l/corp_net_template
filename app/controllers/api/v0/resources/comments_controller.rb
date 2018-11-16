class Api::V0::Resources::CommentsController < Api::ResourceController
  include Likable
  include Api::V0::Resources::Comments

  def index
    render json: @collection.only_top_level.as_json(json_collection_inclusion)
  end

  def show
    render json: @resource_instance.as_json(json_resource_inclusion)
  end

  def create
    can_comment = @resource_instance&.commentable&.respond_to?(:allow_commenting) && @resource_instance&.commentable&.allow_commenting
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

  def destroy
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

  private

  def build_resource
    super
    @resource_instance.assign_attributes(commentable.merge(account_id: current_account.id))
  end

  def commentable
    params.each do |name, value|
      next unless name.match?(/(feed|news|discussion)_id$/)
      model = name.match(%r{([^\/.]+)_id$})
      klass = case model[1]
              when 'feed'
                'post'
              when 'news'
                'news_item'
              else
                model[1]
              end
      return { commentable_type: klass.classify, commentable_id: value&.to_i }
    end
    {}
  end

  def commentable_resource
    commentable[:commentable_type].constantize.find(commentable[:commentable_id])
  end

  def association_chain
    super.where(commentable)
  end

  def permitted_attributes
    %i[id body parent_comment_id]
  end
end
