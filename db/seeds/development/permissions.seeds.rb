print '  creating permissions '
ActiveRecord::Base.transaction do
  [
      {name:'supervisor', description:'Суперпользователь'},
      {name:'menu_create_vacancy_button', description:'Основное меню, создание вакансии'},
      {name:'menu_create_task_button', description:'Основное меню, создание задачи'},
      {name:'vacancies_list_new', description:'Главная страница, список вакансий, новые'},
      {name:'vacancies_list_in_progress', description:'Главная страница, список вакансий, в работе'},
      {name:'add_candidate', description:'Главная страница, работа с кандидатом, добавление кандидата'},
      {name:'find_candidate', description:'Главная страница, работа с кандидатом, найти кандидата'},
      {name:'new_vacancy_1_step_continue', description:'Новая вакансия, 1 шаг, продолжить'},
      {name:'new_vacancy_1_step_save_as_draft', description:'Новая вакансия, 1 шаг, сохранить черновик'},
      {name:'new_vacancy_2_step_continue', description:'Новая вакансия, 2 шаг, продолжить'},
      {name:'new_vacancy_2_step_save_as_draft', description:'Новая вакансия, 2 шаг, сохранить черновик'},
      {name:'new_vacancy_2_step_make_request', description:'Новая вакансия, 2 шаг, создать запрос'},
      {name:'new_vacancy_3_open', description:'Новая вакансия, 2 шаг, открыть вакансию'}
  ].each{|x| Permission.find_or_create_by(x)}
end