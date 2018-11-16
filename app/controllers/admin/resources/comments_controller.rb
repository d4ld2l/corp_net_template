class Admin::Resources::CommentsController < Admin::ResourceController
  def show
    if @resource_instance.commentable_type.in?(%w(Bid))
      redirect_to @resource_instance.commentable
    else
      super
    end
  end

  def create
    if @resource_instance.commentable_type.in?(%w(Bid))
      if @resource_instance.save
        redirect_to @resource_instance.commentable, notice: "Сущность успешно создана"
      else
        redirect_to @resource_instance.commentable, notice: "Ваш комментарий пуст"
      end
    else
      super
    end
  end
end
