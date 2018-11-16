class CreateDefaultUserCompanySeed
  def initialize(company)
    @company = company
  end

  def seed
    set_roles
    password = Devise.friendly_token.first(8)
    user = Account.create(
      company: @company,
      email: "admin_#{@company.subdomain.to_s}@#{@company.domain.present? ? @company.domain : (@company.subdomain.to_s + '.tld')}",
      login: "admin_#{@company.subdomain.to_s}",
      name: 'Иванов',
      surname: 'Иван',
      birthday: Date.today-30.years,
      password: password,
      roles: [ Role.find_or_create_by(name:'admin') ]
    )
    @company.seeds << "Первый: Пользователь #{user.email} с паролем #{password} успешно создан."
  end

  def set_roles
    [
        {name: "admin"},
        {name: "user"},
        {name:'supervisor'}
    ].each{|x| Role.find_or_create_by(x)}
  end

  def role_permissions
    rp = [{
              role: {
                  name: 'admin'
              },
              permission: {
                  name: 'create_request',
                  description: 'Создание заявки',
                  code: 'c_req'
              }
          },
          {
              role: {
                  name: 'admin'
              },
              permission: {
                  name: 'common',
                  description: 'Общее',
                  code: 'common'
              }
          },
          {
              role: {
                  name: 'admin'
              },
              permission: {
                  name: 'create_vacancy',
                  description: 'Создание вакансии',
                  code: 'c_vac'
              }
          },
          {
              role: {
                  name: 'admin'
              },
              permission: {
                  name: 'create_task',
                  description: 'Создание задачи',
                  code: 'c_task'
              }
          },
          {
              role: {
                  name: 'admin'
              },
              permission: {
                  name: 'create_candidate',
                  description: 'Создание кандидата',
                  code: 'c_cand'
              }
          },
          {
              role: {
                  name: 'admin'
              },
              permission: {
                  name: 'update_vacancy',
                  description: 'Редактирование вакансии',
                  code: 'u_vac'
              }
          },
          {
              role: {
                  name: 'admin'
              },
              permission: {
                  name: 'edit_vacancy',
                  description: 'Работа с вакансией',
                  code: 'e_vac'
              }
          },
          {
              role: {
                  name: 'admin'
              },
              permission: {
                  name: 'scoring',
                  description: 'Оценка',
                  code: 'scoring'
              }
          },
          {
              role: {
                  name: 'admin'
              },
              permission: {
                  name: 'create_email',
                  description: 'Создание письма',
                  code: 'c_email'
              }
          },
          {
              role: {
                  name: 'admin'
              },
              permission: {
                  name: 'finance',
                  description: 'Финансы',
                  code: 'fin'
              }
          },
          {
              role: {
                  name: 'admin'
              },
              permission: {
                  name: 'public_vacancy',
                  description: '4-ый шаг создания вакансии: публикация',
                  code: 'p_vac'
              }
          },
          {
              role: {
                  name: 'recruitment_manager'
              },
              permission: {
                  name: 'create_request',
                  description: 'Создание заявки',
                  code: 'c_req'
              }
          },
          {
              role: {
                  name: 'recruitment_manager'
              },
              permission: {
                  name: 'common',
                  description: 'Общее',
                  code: 'common'
              }
          },
          {
              role: {
                  name: 'recruitment_recruiter'
              },
              permission: {
                  name: 'create_request',
                  description: 'Создание заявки',
                  code: 'c_req'
              }
          },
          {
              role: {
                  name: 'recruitment_recruiter'
              },
              permission: {
                  name: 'common',
                  description: 'Общее',
                  code: 'common'
              }
          },
          {
              role: {
                  name: 'recruitment_recruiter'
              },
              permission: {
                  name: 'create_vacancy',
                  description: 'Создание вакансии',
                  code: 'c_vac'
              }
          },
          {
              role: {
                  name: 'recruitment_recruiter'
              },
              permission: {
                  name: 'update_vacancy',
                  description: 'Редактирование вакансии',
                  code: 'u_vac'
              }
          },
          {
              role: {
                  name: 'recruitment_recruiter'
              },
              permission: {
                  name: 'edit_vacancy',
                  description: 'Работа с вакансией',
                  code: 'e_vac'
              }
          },
          {
              role: {
                  name: 'recruitment_recruiter'
              },
              permission: {
                  name: 'create_candidate',
                  description: 'Создание кандидата',
                  code: 'c_cand'
              }
          },
          {
              role: {
                  name: 'finance'
              },
              permission: {
                  name: 'create_apl_expences',
                  description: 'Создание заявки на оформление представительских расходов',
                  code: 'c_apl_exp'
              }
          },
          {
              role: {
                  name: 'assistant'
              },
              permission: {
                  name: 'finance_assistant',
                  description: 'Пользователь является ассистентом, который будет обрабатывать заявку на представительские расходы',
                  code: 'fin_assistant'
              }
          },
          {
              role: {
                  name: 'assistant'
              },
              permission: {
                  name: 'byod_assistant',
                  description: 'Пользователь является ассистентом, который будет обрабатывать заявку на представительские расходы на сервис BYOD',
                  code: 'byod_assist'
              }
          },
          {
              role: {
                  name: 'user'
              },
              permission: {
                  name: 'create_byod',
                  description: 'Создание и работа с заявками сервиса Bring your own device',
                  code: 'create_byod'
              }
          },
          {
              role: {
                  name: 'recruitment_general_recruiter'
              },
              permission: {
                  name: 'create_request',
                  description: 'Создание заявки',
                  code: 'c_req'
              }
          },
          {
              role: {
                  name: 'recruitment_general_recruiter'
              },
              permission: {
                  name: 'create_vacancy',
                  description: 'Создание вакансии',
                  code: 'c_vac'
              }
          },
          {
              role: {
                  name: 'finance'
              },
              permission: {
                  name: 'stuff_info',
                  description: 'Пользователь который может просматривать информацию на вкладке "кадровая информация "',
                  code: 'stuff_info'
              }
          },
          {
              role: {
                  name: 'supervisor'
              },
              permission: {
                  name: 'supervisor',
                  description: 'Суперпользователь',
                  code: 'supervisor'
              }
          },
          {
              role: {
                  name: 'storage_user'
              },
              permission: {
                  name: 'storage_user',
                  description: 'Доступ в хранилище данных как обычный пользователь',
                  code: 'stor_user'
              }
          },
          {
              role: {
                  name: 'storage_admin'
              },
              permission: {
                  name: 'storage_admin',
                  description: 'Доступ в хранилище данных как админ',
                  code: 'stor_admin'
              }
          },
          {
              role: {
                  name: 'assistant'
              },
              permission: {
                  name: 'stb_crud',
                  description: 'создание и редактирование заявки на тимбилдинг',
                  code: 'stb_crud'
              }
          },
          {
              role: {
                  name: 'assistant'
              },
              permission: {
                  name: 'stb_transition',
                  description: 'перевод заявки на тимбилдинг по статусам',
                  code: 'stb_transition'
              }
          },
          {
              role: {
                  name: 'assistant'
              },
              permission: {
                  name: 'stb_report',
                  description: 'выгрузка отчета по заявке на тимбилдинг',
                  code: 'stb_report'
              }
          },
          {
              role: {
                  name: 'admin'
              },
              permission: {
                  name: 'stb_crud',
                  description: 'создание и редактирование заявки на тимбилдинг',
                  code: 'stb_crud'
              }
          },
          {
              role: {
                  name: 'admin'
              },
              permission: {
                  name: 'stb_transition',
                  description: 'перевод заявки на тимбилдинг по статусам',
                  code: 'stb_transition'
              }
          },
          {
              role: {
                  name: 'admin'
              },
              permission: {
                  name: 'stb_report',
                  description: 'выгрузка отчета по заявке на тимбилдинг',
                  code: 'stb_report'
              }
          },
          {
              role: {
                  name: 'finance'
              },
              permission: {
                  name: 'stb_crud',
                  description: 'создание и редактирование заявки на тимбилдинг',
                  code: 'stb_crud'
              }
          },
          {
              role: {
                  name: 'finance'
              },
              permission: {
                  name: 'stb_transition',
                  description: 'перевод заявки на тимбилдинг по статусам',
                  code: 'stb_transition'
              }
          }
    ]
    rp.each do |rr|
      r = Role.find_or_create_by(name: rr.dig(:role, :name))
      p = Permission.find_or_create_by(rr[:permission])
      prp = RolePermission.find_or_initialize_by(role: r, permission: p)
      prp.save validate: false
    end
  end
end
