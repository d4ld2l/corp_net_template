print '  creating roles '
ActiveRecord::Base.transaction do
  roles = %w( admin user recruiter general_recruiter manager hr project_manager)
  roles.each do |name|
    Role.find_or_create_by(name: name)
  end

  Role.where.not(name: roles).delete_all

  puts " (#{Role.count})"
end

print ' creating permissions and adds all permissions to admin role '
r_permissions = [{name:'supervisor', description:'Суперпользователь', code: 'supervisor'},
                 {"name"=>"create_request", "description"=>"Создание заявки", "code"=>"c_req"},
                 {"name"=>"common", "description"=>"Общее", "code"=>"common"},
                 {"name"=>"create_vacancy", "description"=>"Создание вакансии", "code"=>"c_vac"},
                 {"name"=>"create_task", "description"=>"Создание задачи", "code"=>"c_task"},
                 {"name"=>"create_candidate", "description"=>"Создание кандидата", "code"=>"c_cand"},
                 {"name"=>"update_vacancy", "description"=>"Редактирование вакансии", "code"=>"u_vac"},
                 {"name"=>"edit_vacancy", "description"=>"Работа с вакансией", "code"=>"e_vac"},
                 {"name"=>"scoring", "description"=>"Оценка", "code"=>"scoring"},
                 {"name"=>"create_email", "description"=>"Создание письма", "code"=>"c_email"},
                 {"name"=>"finance", "description"=>"Финансы", "code"=>"fin"},
                 {"name"=>"public_vacancy", "description"=>"4-ый шаг создания вакансии: публикация", "code"=>"p_vac"}
]

permissions = r_permissions.map{|x| Permission.create(x)}

Role.find_by(name:'admin').permissions = permissions