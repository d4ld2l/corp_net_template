class VacancyUpdateMailer < ApplicationMailer
  def send_email(user, vacancy, email)
    subject = "Обновлена вакансия #{vacancy.name}"
    @body = "Пользователь #{user.full_name} обновил вакансию <a href=\"#{ENV['FRONT_HOST']}/recruitment/vacancies/#{vacancy.id}\">#{vacancy.name}</a>"
    mail(to: email, from: ENV['FROM_MAIL'], subject: subject)
  end
end
