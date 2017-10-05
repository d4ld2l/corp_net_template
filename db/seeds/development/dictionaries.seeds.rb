puts 'creating contract types'
['Основной договор', 'Совместительство', 'Срочный договор', 'Бессрочный договор'].each { |x| ContractType.create(name: x) }

puts 'creating event types'
['Спортивное', 'Культурное', 'Встреча', 'Собеседование', 'Другое'].each { |x| EventType.create(name: x) }