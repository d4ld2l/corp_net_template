class AssessmentSessionsMailer < ApplicationMailer
  include ActionView::Helpers::UrlHelper

  def reminder_notification(account_full_name, session_id, email)
    @account_full_name = account_full_name
    subject = 'Напоминание о прохождении оценки'
    @link = "<a href=\"#{ENV['FRONT_HOST']}/assessments/#{session_id}/session\">Перейти к оценке</a>".html_safe
    mail(to: email, subject: subject, from: ENV['FROM_MAIL'])
  end

  def invitation_notification(account_full_name, session_id, email)
    @account_full_name = account_full_name
    subject = 'Прохождении оценки'
    @link = "<a href=\"#{ENV['FRONT_HOST']}/assessments/#{session_id}/session\">Перейти к оценке</a>".html_safe
    mail(to: email, subject: subject, from: ENV['FROM_MAIL'])
  end

  def completed_notification(account_full_name, session_id, email)
    @account_full_name = account_full_name
    subject = 'Прохождении оценки'
    @link = "<a href=\"#{ENV['FRONT_HOST']}/assessments/#{session_id}\">#{@account_full_name}</a>".html_safe
    mail(to: email, subject: subject, from: ENV['FROM_MAIL'])
  end

  def close_notification(session_id, email)
    subject = 'Прохождении оценки'
    @link = "<a href=\"#{ENV['FRONT_HOST']}/assessments/#{session_id}\"> результаты</a>".html_safe
    mail(to: email, subject: subject, from: ENV['FROM_MAIL'])
  end

end
