class DchVacancyNotificationsWorker
  include Sidekiq::Worker

  def perform(vacancy, users, event, author=nil)
    @author  = author
    @vacancy = JSON.parse vacancy
    users.each{|uid| ExternalIntegrations::DchApi.new(body(uid, event)).send_notification }
  end

  private
  def body uid, event
    { uid: uid, message: send(event) }
  end

  def vacancy_created
    "Открыта новая вакансия: #{@vacancy['name']}.\n" +
    "Менеджер по вакансии: #{@vacancy['manager']}." +
    vacancy_link
  end

  def vacancy_updated
    "Вакансия #{@vacancy['name']} была отредактирована.\n" +
    "Автор действия: #{@vacancy['manager']}." +
    vacancy_link
  end

  def vacancy_cancelled
    "Вакансия #{@vacancy['name']} была отменена.\n" +
    "Автор действия: #{@vacancy['manager']}." +
    vacancy_link
  end

  def vacancy_paused
    "Работа по вакансии #{@vacancy['name']} приостановлена.\n" +
    "Автор действия: #{@author}." +
    vacancy_link
  end

  def vacancy_in_progress
    "Вакансия #{@vacancy['name']} взята в работу.\n" +
    "Рекрутер: #{@vacancy['recruiter']}." +
    vacancy_link
  end

  def vacancy_assignment
    "На вас назначена вакансия: #{@vacancy['name']}." +
    vacancy_link
  end

  def new_vacancy_assignment
    "На вас назначена новая вакансия: #{@vacancy['name']}.\n" +
    "Менеджер по вакансии: #{@vacancy['manager']}." +
    vacancy_link
  end

  def status_changed
    actor = @vacancy['current_account_full_name']
    res = ''
    if actor
      res += "#{@vacancy['current_account_full_name']} изменил статус вакансии #{@vacancy['name']} на #{@vacancy['status']}.\n"
    else
      res += "Статус вакансии #{@vacancy['name']} был изменен на #{@vacancy['status']}.\n"
    end
    res + vacancy_link
  end

  def new_accounts_added
    "Вас добавили к вакансии #{@vacancy['name']} как эксперта." + vacancy_link
  end

  private

  def vacancy_link
    "\nПосмотреть вакансию тут: #{ENV['FRONT_HOST']}/recruitment/vacancies/#{@vacancy['id']}"
  end
end
