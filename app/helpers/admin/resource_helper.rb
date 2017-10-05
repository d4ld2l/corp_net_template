module Admin::ResourceHelper

  def index_edit_button(resource)
    link_to [:edit, resource], class: 'btn btn-success btn-simple btn-xs' do
      content_tag(:i, '', class: 'fa fa-edit')
    end
  end

  def index_delete_button(resource)
    link_to resource, method: :delete, class: 'btn btn-danger btn-simple btn-xs' do
      content_tag(:i, '', class: 'fa fa-remove')
    end
  end

  def errors_for(model, attribute, code = nil)
    if code
      index = model.errors.details[attribute].index { |d| d[:error] == code }
      return unless index
      errors = [model.errors[attribute][index]]
    else
      errors = model.errors[attribute]
    end

    if errors.any?
      content_tag(:div, errors.to_sentence, class: 'alert alert-danger with-errors')
    end
  end

  def link_to_profile(label, object, html = {})
    if link ||= object.last && link_to(label, object, html)
      link
    else
      label
    end
  end
end
