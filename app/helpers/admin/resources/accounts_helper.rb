module Admin::Resources::AccountsHelper
  def change_account_status_button(account)
    if account.active?
      link_to to_blocked_account_path(account), class: 'btn btn-info btn-simple btn-xs', rel: 'tooltip', title: 'Блокировать', method: :post do
        content_tag :i, nil, class: 'fa fa-lock'
      end
    else
      link_to to_active_account_path(account), class: 'btn btn-info btn-simple btn-xs', rel: 'tooltip', title: 'Разблокировать', method: :post do
        content_tag :i, nil, class: 'fa fa-unlock'
      end
    end
  end

  def account_duplicate_tooltip_title(account)
    res = ''
    if account
      res = "ФИО: #{account.full_name}, дата рождения: #{account.birthday || 'не указана'}"
    else
      res = 'Профиль не создан'
    end
    res
  end

  def change_account_status_button(account)
    if account.active?
      link_to to_blocked_account_path(account), class: 'btn btn-info btn-simple btn-xs', rel: 'tooltip', title: 'Блокировать', method: :post do
        content_tag :i, nil, class: 'fa fa-lock'
      end
    else
      link_to to_active_account_path(account), class: 'btn btn-info btn-simple btn-xs', rel: 'tooltip', title: 'Разблокировать', method: :post do
        content_tag :i, nil, class: 'fa fa-unlock'
      end
    end
  end

end
