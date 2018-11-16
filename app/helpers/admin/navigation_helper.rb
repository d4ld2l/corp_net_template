module Admin::NavigationHelper

  def head_navigation_element(class_name, localized_name, link, without_access_check=false)
    if can?(:see_menu, class_name) || without_access_check
      content_tag :li do
        link_to(localized_name, link)
      end
    end
  end

  def head_navigation_dropdown(name)
    content_tag :li, class: 'dropdown' do
      content_tag(:a, class:'dropdown-toggle', data:{toggle:'dropdown'}, href:'#') {
        content_tag(:span, name) + content_tag(:b, nil,class: 'caret')
      } +
          content_tag(:ul, class: 'dropdown-menu') do
            yield
          end
    end
  end

  def head_navigation_submenu_1(name)
    content_tag :li, class: 'dropdown-submenu' do
      content_tag(:a, class:'dropdown-toggle', data:{toggle:'dropdown-submenu'}, href:'#') {
        content_tag(:span, name) + content_tag(:b, nil,class: 'caret')
      } +
          content_tag(:ul, class: 'dropdown-menu') do
            yield
          end
    end
  end

end
