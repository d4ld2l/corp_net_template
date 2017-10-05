module Admin::Resources::LegalUnitsHelper
  def index_edit_employees_button(resource)
    link_to [:edit_employees, resource], class: 'btn btn-default btn-simple btn-xs', 'data-toggle':"tooltip", 'title':"Редактировать сотрудников" do
      content_tag(:i, '', class: 'fa fa-users')
    end
  end
end
