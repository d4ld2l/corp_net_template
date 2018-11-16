module Admin::Resources::AdminSettingsHelper
  def value_label(kind, value)
    if kind == 'boolean'
      value == '1' ? 'Да' : 'Нет'
    else
      value
    end
  end
end
