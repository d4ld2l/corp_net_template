class DchCandidateNotificationsWorker
  include Sidekiq::Worker

  def perform(vacancy, candidate, event, user)
    @vacancy  = vacancy
    @candidate = candidate
    ExternalIntegrations::DchApi.new(body(user, event)).send_notification
  end

  private
  def body uid, event
    { uid: uid, message: send(event) }
  end

  def accept
    "Кандидат #{@candidate['name']} принял оффер по вакансии #{@vacancy['name']}"
  end

  def reject
    "Кандидат #{@candidate['name']} отказался от оффера по вакансии #{@vacancy['name']}"
  end

  def attached
    "В вакансию #{@vacancy['name']} (#{ENV['FRONT_HOST']}/recruitment/vacancies/#{@vacancy['id']}) добавлен кандидат #{@candidate['name']}"
  end

  def transition
    "Кандидат #{@candidate['name']} переведен в статус #{@candidate['status']} по вакансии #{@vacancy['name']}"
  end
end
