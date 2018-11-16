class AddOfferAcceptedToStandardTemplate < ActiveRecord::Migration[5.0]
  def data
    t = TemplateStage.find_or_create_by(name:'Стандартный')
    t.vacancy_stages.find_by_name('Оффер')&.update_attribute(:name, 'Оффер выставлен')
    t.vacancy_stages.find_by_name('Отказ')&.update_attribute(:position, 9)
    t.vacancy_stages.find_by_name('Принят')&.update_attribute(:position, 8)
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
  end
end
