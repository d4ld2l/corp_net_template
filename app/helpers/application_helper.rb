module ApplicationHelper

  def resource_page_header(text)
    render 'shared/form_header', text: text
  end

end
