print '  creating template_stages_groups '
ActiveRecord::Base.transaction do
  [
      {label:'Новые', value:'new', color:'#f58223'},
      {label:'Скрининг', value:'screening', color:'#20c58f'},
      {label:'Интервью', value:'interview', color:'#8b572a'},
      {label:'Согласование', value:'harmonization', color:'#d16ca8'},
      {label:'Оффер', value:'offer', color:'#9176d8'},
      {label:'Принят', value:'accepted', color:'#417505'},
      {label:'Отказ', value:'rejected', color:'#d0021b'},
      {label:'Архив', value:'archived', color:'#93959a'}
  ].each_with_index{|x| VacancyStageGroup.find_or_create_by(label: x[:label]).update_attributes(x)}


  [
      {value:'new'},
      {value:'screening'},
      {value:'interview'},
      {value:'harmonization'},
      {value:'offer'},
      {value:'accepted'},
      {value:'rejected'},
      {value:'archived'}
  ].each_with_index{|x, i| VacancyStageGroup.find_by(x).update_attributes(position: i)}

  puts 'create template stage "Базовый"'
  t = TemplateStage.find_or_create_by(name:'Базовый')
  t.vacancy_stages = [
    VacancyStage.create({need_notification: false,
                        evaluation_of_candidate: false,
                        type_of_rating: 'passing',
                        position:0,
                        editable: false,
                        must_be_last:false,
                        vacancy_stage_group: VacancyStageGroup.find_by_value('new'),
                        name: 'Добавлены',
                        can_create_left: false,
                        can_create_right:false
                                   }
    ),
    VacancyStage.create({need_notification: true,
                        evaluation_of_candidate: false,
                        type_of_rating: 'ten_point_scale',
                        position:2,
                        editable: false,
                        must_be_last:false,
                        vacancy_stage_group: VacancyStageGroup.find_by_value('accepted'),
                        name: 'Принят',
                        can_create_left: true,
                        can_create_right:false}
    ),
    VacancyStage.create({need_notification: false,
                        evaluation_of_candidate: false,
                        type_of_rating: 'passing',
                        position:nil,
                        editable: false,
                        must_be_last:true,
                        vacancy_stage_group: VacancyStageGroup.find_by_value('rejected'),
                        name: 'Отказ',
                        can_create_left: false,
                        can_create_right:false}
    ),
  ]
  t.save


  puts 'create template stage "Стандартный"'
  t = TemplateStage.find_or_create_by(name:'Стандартный')
  t.vacancy_stages = [
      VacancyStage.create({need_notification: false,
                           evaluation_of_candidate: false,
                           position: 0,
                           editable: false,
                           must_be_last: false,
                           vacancy_stage_group: VacancyStageGroup.find_by_value('new'),
                           name: 'Добавлены',
                           can_create_left: false,
                           can_create_right: false
                          })
  ]
  t.vacancy_stages += [
      VacancyStage.create({need_notification: false,
                           evaluation_of_candidate: true,
                           type_of_rating: 'passing',
                           position: 2,
                           editable: true,
                           must_be_last: false,
                           vacancy_stage_group: VacancyStageGroup.find_by_value('screening'),
                           name: 'Скрининг рекрутера',
                           can_create_left: true,
                           can_create_right: true})
  ]
  t.vacancy_stages += [
      VacancyStage.create({need_notification: true,
                           evaluation_of_candidate: true,
                           type_of_rating: 'passing',
                           position: 3,
                           editable: true,
                           must_be_last: false,
                           vacancy_stage_group: VacancyStageGroup.find_by_value('screening'),
                           name: 'Скрининг менеджера',
                           can_create_left: true,
                           can_create_right: true})
  ]
  t.vacancy_stages += [
      VacancyStage.create({need_notification: false,
                           evaluation_of_candidate: true,
                           type_of_rating: 'passing',
                           position: 4,
                           editable: true,
                           must_be_last: false,
                           vacancy_stage_group: VacancyStageGroup.find_by_value('interview'),
                           name: 'Интервью рекрутера',
                           can_create_left: true,
                           can_create_right: true})
  ]
  t.vacancy_stages += [
      VacancyStage.create({need_notification: true,
                           evaluation_of_candidate: true,
                           type_of_rating: 'passing',
                           position: 5,
                           editable: true,
                           must_be_last: false,
                           vacancy_stage_group: VacancyStageGroup.find_by_value('interview'),
                           name: 'Интервью менеджера',
                           can_create_left: true,
                           can_create_right: true})
  ]
  t.vacancy_stages += [
      VacancyStage.create({need_notification: true,
                           evaluation_of_candidate: false,
                           position: 6,
                           editable: true,
                           must_be_last: false,
                           vacancy_stage_group: VacancyStageGroup.find_by_value('offer'),
                           name: 'Оффер выставлен',
                           can_create_left: true,
                           can_create_right: true})
  ]
  t.vacancy_stages += [
      VacancyStage.create({need_notification: false,
                           evaluation_of_candidate: false,
                           position: 7,
                           editable: true,
                           must_be_last: false,
                           vacancy_stage_group: VacancyStageGroup.find_by_value('offer'),
                           name: 'Оффер принят',
                           can_create_left: true,
                           can_create_right: true})
  ]
  t.vacancy_stages += [
      VacancyStage.create({need_notification: false,
                           evaluation_of_candidate: false,
                           position: 8,
                           editable: false,
                           must_be_last: false,
                           vacancy_stage_group: VacancyStageGroup.find_by_value('accepted'),
                           name: 'Принят',
                           can_create_left: true,
                           can_create_right: false})
  ]
  t.vacancy_stages += [
      VacancyStage.create({need_notification: false,
                           evaluation_of_candidate: false,
                           position: 9,
                           editable: false,
                           must_be_last: true,
                           vacancy_stage_group: VacancyStageGroup.find_by_value('rejected'),
                           name: 'Отказ',
                           can_create_left: false,
                           can_create_right: false})
  ]
  t.save

  puts 'clear old vacancy_stages'
  VacancyStage.where(vacancy_id:nil, template_stage_id:nil).each(&:delete)
end