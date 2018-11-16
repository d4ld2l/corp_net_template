class AutoNotificationsMailer < ApplicationMailer
  def vacancy_created(vacancy, to)
    @vacancy = JSON.parse vacancy
    mail(from: ENV['FROM_MAIL'], to: to, subject: 'Новая вакансия') unless to.blank?
  end

  def vacancy_assigned(vacancy, to)
    @vacancy = JSON.parse vacancy
    mail(from: ENV['FROM_MAIL'], to: to, subject: 'Назначена новая вакансия') unless to.blank?
  end

  def vacancy_in_progress(vacancy, to)
    @vacancy = JSON.parse vacancy
    mail(from: ENV['FROM_MAIL'], to: to, subject: 'Вакансия взята в работу') unless to.blank?
  end

  def vacancy_update(vacancy, to, state)
    @vacancy = JSON.parse vacancy
    @state = state
    mail(from: ENV['FROM_MAIL'], to: to, subject: "Вакансия была #{@state}") unless to.blank?
  end

  def vacancy_paused(vacancy, to, author)
    @vacancy = JSON.parse vacancy
    @author = author
    mail(from: ENV['FROM_MAIL'], to: to, subject: 'Работа по вакансии приостановлена') unless to.blank?
  end

  def offer_status_changed(candidate, vacancy, state, to)
    @vacancy = vacancy
    @candidate = candidate
    @state = state
    mail(from: ENV['FROM_MAIL'], to: to, subject: "Кандидат #{state}") unless to.blank?
  end
end
