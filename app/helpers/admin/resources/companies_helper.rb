module Admin::Resources::CompaniesHelper
  def make_default_tenant_button(resource)
    unless resource&.default?
      link_to [:make_default, resource], method: :post, class: 'btn btn-default btn-simple btn-xs', 'data-toggle':"tooltip", 'title':"Сделать тенантом по-умолчанию" do
        content_tag(:i, '', class: 'fa fa-home')
      end
    end
  end
end
