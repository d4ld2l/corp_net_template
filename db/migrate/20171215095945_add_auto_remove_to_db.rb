class AddAutoRemoveToDb < ActiveRecord::Migration[5.0]
  def data
    AdminSetting.find_or_create_by!(name: 'auto_news_destroy', value: '1', kind: :boolean, label: 'Удаление новостей о новых сотрудниках и днях рождения (автоматически)')
  end
end
