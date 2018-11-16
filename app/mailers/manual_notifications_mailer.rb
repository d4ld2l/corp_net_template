class ManualNotificationsMailer < ApplicationMailer
  def send_email(to, copy, subject, body)
    @body = body
    mail(from: ENV['FROM_MAIL'],to: to, cc: copy, subject: subject)
  end
end
