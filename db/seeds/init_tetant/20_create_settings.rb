class CreateSettingsCompanySeed
  def initialize(company)
    @company = company
  end

  def seed
    text = SettingsGroup.find_or_create_by(label:'Текстовые переменные', code:'text', company_id: @company&.id)
    [
        {
            code: 'why_need_to_fill_profile',
            kind: :text,
            label:'Отображать в поле "Зачем заполнять раздел?"',
            value:'Заполните данный раздел и получите одну валюту'
        }
    ].each{|x| Setting.find_or_create_by(x.merge({company: @company, settings_group:text}))}

    admin = SettingsGroup.find_or_create_by(label:'Настройки тенанта', code: 'admin', company_id: @company&.id)
    [
        {code: 'notify_all_on_news_published', value: '1', kind: :boolean, label: 'Рассылать всем на почту уведомления о публикации новости'},
        {code: 'auto_birthday', value: '1', kind: :boolean, label: 'Формирование новости о днях рождениях (автоматически)'},
        {code: 'auto_employee', value: '1', kind: :boolean, label: 'Формирование новости о новых сотрудниках (автоматически)'},
        {code: 'auto_news_destroy', value: '1', kind: :boolean, label: 'Удаление новостей о новых сотрудниках и днях рождения (автоматически)'}
    ].each{|x| Setting.find_or_create_by(x.merge({company: @company, settings_group:admin}))}

    menu = SettingsGroup.find_or_create_by(label:'Настройки меню', code: 'menu', company_id: @company&.id)
    [
        {code: 'news', value: 'Новости', kind: :text, label: 'Название меню новостей'},
        {code: 'services', value: 'Сервисы', kind: :text, label: 'Название меню сервисов'},
        {code: 'surveys', value: 'Опросы', kind: :text, label: 'Название меню опросов'},
        {code: 'employees', value: 'Сотрудники', kind: :text, label: 'Название меню сотрудников'},
        {code: 'hr', value: 'Рекрутинг', kind: :text, label: 'Название меню рукрутинга'},
        {code: 'projects', value: 'Проекты', kind: :text, label: 'Название меню проектов'},
        {code: 'tasks', value: 'Задачи', kind: :text, label: 'Название меню задач'},
        {code: 'community', value: 'Лента', kind: :text, label: 'Название меню ленты'},
        {code: 'discussion', value: 'Обсуждения', kind: :text, label: 'Название меню обсуждений'},
        {code: 'storage', value: 'Документы', kind: :text, label: 'Название меню ХД'}
    ].each{|x| Setting.find_or_create_by(x.merge({company: @company, settings_group:menu}))}
  end
end
