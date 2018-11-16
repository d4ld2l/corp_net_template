class DchNotificationsWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'notifications', retry: true

  def perform(vacancy, users)
    @vacancy = JSON.parse vacancy
    users.each { |uid| ExternalIntegrations::DchApi.new(body(uid)).send_notification }
  end

  private

  def body(uid)
    { uid: uid, message: message }
  end

  def message
    "Открыта новая вакансия: #{@vacancy['name']}, блок #{@vacancy['block']}, практика #{@vacancy['practice']}.\n\
Менеджер вакансии: #{@vacancy['manager']}.\n\
Посмотреть вакансию можно тут #{ENV['FRONT_HOST']}/recruitment/vacancies/#{@vacancy['id']}"
  end
end
