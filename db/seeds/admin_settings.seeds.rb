AdminSetting.find_or_create_by!(name: 'auto_birthday', value: '1', kind: :boolean, label: 'Формирование новости о днях рождениях (автоматически)')
AdminSetting.find_or_create_by!(name: 'auto_employee', value: '1', kind: :boolean, label: 'Формирование новости о новых сотрудниках (автоматически)')
AdminSetting.find_or_create_by!(name: 'auto_news_destroy', value: '1', kind: :boolean, label: 'Удаление новостей о новых сотрудниках и днях рождения (автоматически)')