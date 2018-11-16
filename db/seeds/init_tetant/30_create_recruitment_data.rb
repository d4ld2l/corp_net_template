class CreateRecruitmentDataCompanySeed
  def initialize(company)
    @company = company
  end

  def seed
    ActsAsTenant.with_tenant(@company) do
      vacancy_stage_groups
      template_stages
      education_levels
      language_levels
      languages
      professional_areas
    end
  end

  def education_levels
    [
        {name: "Высшее"},
        {name: "Начальное"},
        {name: "Среднее"},
        {name: "Среднее специальное"},
        {name: "Бакалавр"},
        {name: "Неоконченное высшее"}
    ].each{ |x| EducationLevel.find_or_create_by(x) }
  end

  def languages
    [
        {name: "Русский"},
        {name: "Английский"},
        {name: "Французский"},
        {name: "Венгерский"},
        {name: "Немецкий"},
        {name: "Украинский"},
        {name: "Японский"},
        {name: "Эсперанто"},
        {name: "Греческий"}
    ].each{ |x| Language.find_or_create_by(x) }
  end

  def language_levels
    [
        {name: "Не владею", value: 1},
        {name: "Базовые знания", value: 2},
        {name: "Читаю профессиональную литературу", value: 3},
        {name: "Могу проходить интервью", value: 4},
        {name: "Свободно владею", value: 5},
        {name: "Родной", value: 5}
    ].each{ |x| LanguageLevel.find_or_create_by(x) }
  end

  def professional_areas
    [
        {
            name: "Разработка",
            professional_specializations_attributes:[
                {professional_area_id: 1, name: "Ruby On Rails"}
            ]
        },
        {
            name: "Информационные технологии, интернет, телеком",
            professional_specializations_attributes:[
                {name: "Консалтинг, Аутсорсинг"},
                {name: "CTO, CIO, Директор по IT"},
                {name: "Управление проектами"},
                {name: "Технический писатель"},
                {name: "Программирование, Разработка"},
                {name: "Системная интеграция"},
                {name: "Аналитик"},
                {name: "Тестирование"},
                {name: "Системы управления предприятием (ERP)"},
                {name: "CRM системы"},
                {name: "Интернет"},
                {name: "Web инженер"},
                {name: "Web мастер"},
                {name: "Инженер"}
            ]
        },
        {
            name: "Консультирование",
            professional_specializations_attributes:[
                {professional_area_id: 3, name: "Реинжиниринг бизнес процессов"},
                {professional_area_id: 3, name: "Организационное консультирование"},
                {professional_area_id: 3, name: "Стратегия"},
            ]
        },
        {
            name: "Начало карьеры, студенты",
            professional_specializations_attributes:[
                {name: "Информационные технологии, Интернет, Мультимедиа"}
            ]
        },
        {
            name: "Маркетинг, реклама, PR",
            professional_specializations_attributes:[
                {professional_area_id: 5, name: "Планирование, Размещение рекламы"},
                {professional_area_id: 5, name: "Управление проектами"},
                {professional_area_id: 5, name: "Интернет-маркетинг"}
            ]
        }
    ].each{ |x| ProfessionalArea.create(x) }
  end

  def vacancy_stage_groups
    [
        {label: "Новые", color: "#f58223", value: "new", position: 0},
        {label: "Скрининг", color: "#20c58f", value: "screening", position: 1},
        {label: "Интервью", color: "#8b572a", value: "interview", position: 2},
        {label: "Согласование", color: "#d16ca8", value: "harmonization", position: 3},
        {label: "Оффер", color: "#9176d8", value: "offer", position: 4},
        {label: "Принят", color: "#417505", value: "accepted", position: 5},
        {label: "Отказ", color: "#d0021b", value: "rejected", position: 6},
        {label: "Архив", color: "#93959a", value: "archived", position: 7}
    ].each{|x| VacancyStageGroup.find_or_create_by(x)}
  end

  def template_stages
    [
        {name: "Базовый"},
        {name: "Стандартный"}
    ].each{|x| TemplateStage.find_or_create_by(x)}

    new = VacancyStageGroup.find_by(value: "new")
    screening = VacancyStageGroup.find_by(value: "screening")
    interview = VacancyStageGroup.find_by(value: "interview")
    harmonization = VacancyStageGroup.find_by(value: "harmonization")
    offer = VacancyStageGroup.find_by(value: "offer")
    accepted = VacancyStageGroup.find_by(value: "accepted")
    rejected = VacancyStageGroup.find_by(value: "rejected")
    archived = VacancyStageGroup.find_by(value: "archived")

    [
        {vacancy_id: nil, need_notification: false, evaluation_of_candidate: false, type_of_rating: "passing", template_stage: TemplateStage.find_or_create_by(name: "Базовый"), position: 0, editable: false, must_be_last: false, name: "Добавлены", group_name: nil, vacancy_stage_group: new, can_create_left: false, can_create_right: false},
        {vacancy_id: nil, need_notification: true, evaluation_of_candidate: false, type_of_rating: "ten_point_scale", template_stage: TemplateStage.find_or_create_by(name: "Базовый"), position: 2, editable: false, must_be_last: false, name: "Принят", group_name: nil, vacancy_stage_group: accepted, can_create_left: true, can_create_right: false},
        {vacancy_id: nil, need_notification: false, evaluation_of_candidate: false, type_of_rating: "passing", template_stage: TemplateStage.find_or_create_by(name: "Базовый"), position: nil, editable: false, must_be_last: true, name: "Отказ", group_name: nil, vacancy_stage_group: rejected, can_create_left: false, can_create_right: false},
        {vacancy_id: nil, need_notification: false, evaluation_of_candidate: false, type_of_rating: nil, template_stage: TemplateStage.find_or_create_by(name: "Стандартный"), position: 0, editable: false, must_be_last: false, name: "Добавлены", group_name: nil, vacancy_stage_group: new, can_create_left: false, can_create_right: false},
        {vacancy_id: nil, need_notification: false, evaluation_of_candidate: true, type_of_rating: "passing", template_stage: TemplateStage.find_or_create_by(name: "Стандартный"), position: 2, editable: true, must_be_last: false, name: "Скрининг рекрутера", group_name: nil, vacancy_stage_group: screening, can_create_left: true, can_create_right: true},
        {vacancy_id: nil, need_notification: true, evaluation_of_candidate: true, type_of_rating: "passing", template_stage: TemplateStage.find_or_create_by(name: "Стандартный"), position: 3, editable: true, must_be_last: false, name: "Скрининг менеджера", group_name: nil, vacancy_stage_group: screening, can_create_left: true, can_create_right: true},
        {vacancy_id: nil, need_notification: false, evaluation_of_candidate: true, type_of_rating: "passing", template_stage: TemplateStage.find_or_create_by(name: "Стандартный"), position: 4, editable: true, must_be_last: false, name: "Интервью рекрутера", group_name: nil, vacancy_stage_group: interview, can_create_left: true, can_create_right: true},
        {vacancy_id: nil, need_notification: true, evaluation_of_candidate: true, type_of_rating: "passing", template_stage: TemplateStage.find_or_create_by(name: "Стандартный"), position: 5, editable: true, must_be_last: false, name: "Интервью менеджера", group_name: nil, vacancy_stage_group: interview, can_create_left: true, can_create_right: true},
        {vacancy_id: nil, need_notification: false, evaluation_of_candidate: false, type_of_rating: nil, template_stage: TemplateStage.find_or_create_by(name: "Стандартный"), position: 9, editable: nil, must_be_last: true, name: "Отказ", group_name: nil, vacancy_stage_group: rejected, can_create_left: false, can_create_right: false},
        {vacancy_id: nil, need_notification: false, evaluation_of_candidate: false, type_of_rating: nil, template_stage: TemplateStage.find_or_create_by(name: "Стандартный"), position: 8, editable: false, must_be_last: false, name: "Принят", group_name: nil, vacancy_stage_group: accepted, can_create_left: true, can_create_right: false},
        {vacancy_id: nil, need_notification: false, evaluation_of_candidate: false, type_of_rating: nil, template_stage: TemplateStage.find_or_create_by(name: "Стандартный"), position: 7, editable: true, must_be_last: false, name: "Оффер принят", group_name: nil, vacancy_stage_group: offer, can_create_left: true, can_create_right: true},
        {vacancy_id: nil, need_notification: true, evaluation_of_candidate: false, type_of_rating: nil, template_stage: TemplateStage.find_or_create_by(name: "Стандартный"), position: 6, editable: true, must_be_last: false, name: "Оффер выставлен", group_name: nil, vacancy_stage_group: offer, can_create_left: true, can_create_right: true},
    ].each{|x| VacancyStage.find_or_create_by(x)}

  end
end