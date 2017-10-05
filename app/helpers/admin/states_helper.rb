module Admin::StatesHelper
  def publish_link(resource)
    state_link(resource, :publish, :to_published, 'Опубликовать')
  end

  def unpublish_link(resource)
    state_link(resource, :unpublish, :to_unpublished, 'Снять с публикации')
  end

  def archive_link(resource)
    state_link(resource, :archive, :to_archived, 'В архив')
  end

  def repair_link(resource)
    state_link(resource, :repair, :to_draft, 'В черновики')
  end

  def state_link(resource, state, transition, name)
    if resource.send("may_#{transition}?")
      link_to(name, [state, resource], method: :post, class: 'btn btn-info').html_safe
    end
  end
end
