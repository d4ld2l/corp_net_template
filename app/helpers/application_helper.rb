module ApplicationHelper

  def resource_page_header(text)
    render 'shared/form_header', text: text
  end

  def ce?(component_name)
    current_tenant&.component_enabled?(component_name)
  end

end
