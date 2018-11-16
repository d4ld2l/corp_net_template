class NewVacancyMailer < ApplicationMailer
  def send_email(vacancy, email)
    subject = "Новая вакансия #{vacancy.name}"
    @body = "В системе создана новая вакансия <a href=\"#{ENV['FRONT_HOST']}/recruitment/vacancies/#{vacancy.id}\">#{vacancy.name}</a>"
    mail(to: email, from: ENV['FROM_MAIL'], subject: subject)
  end
end
