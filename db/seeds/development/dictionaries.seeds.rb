puts 'creating languages'
['Русский', 'Английский'].each { |x| Language.find_or_create_by(name: x) }

puts 'creating language levels'
[{name: 'Не владею', value: 1},{name: 'Базовые знания', value: 2},
{name: 'Читаю профессиональную литературу', value: 3},{name: 'Могу проходить интервью', value: 4},
 {name: 'Свободно владею', value: 5}, {name: 'Родной', value: 5}].each { |x| LanguageLevel.find_or_create_by(name: x[:name]).update(x) }

puts 'creating education levels'
['Начальное', 'Среднее', 'Среднее специальное', 'Высшее'].each { |x| EducationLevel.create(name: x) }

puts 'creating professional areas'
['Область 1', 'Область 2'].each { |x| ProfessionalArea.find_or_create_by(name: x) }

puts 'creating professional areas'
['Специализация 1', 'Специализация 2'].each { |x| ProfessionalSpecialization.find_or_create_by(name: x, professional_area_id: ProfessionalArea.first) }
['Специализация 3', 'Специализация 4'].each { |x| ProfessionalSpecialization.find_or_create_by(name: x, professional_area_id: ProfessionalArea.last) }

puts 'creating vacancy stage groups'
[{ label: 'Скриннинг', value: 'screening', color: '#f00' },
 { label: 'Тестирование', value: 'testing', color: '#0f0' },
 { label: 'Интервью', value: 'interviewing', color: '#00f' },
 { label: 'Решение', value: 'decision', color: '#ff0' }].each { |x| VacancyStageGroup.find_or_create_by(x) }

puts ' creating resume_sources '
['HeadHunter', 'SuperJob', 'Rabota.ru', 'career.ru', 'Зарплата.ru', 'Мой круг', 'Другое'].each { |x| ResumeSource.create(name: x)}

puts 'creating contract types'
['Основной договор', 'Совместительство', 'Срочный договор', 'Бессрочный договор'].each { |x| ContractType.create(name: x) }

puts 'creating event types'
['Спортивное', 'Культурное', 'Встреча', 'Собеседование', 'Другое'].each { |x| EventType.create(name: x) }