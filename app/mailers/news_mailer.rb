class NewsMailer < ApplicationMailer
  include ActionView::Helpers::UrlHelper
  
  def notification_about_publishing(news_name, news_id, emails)
    subject = 'Опубликована новость'
    @link = "<a href=\"#{ENV['FRONT_HOST']}/news/#{news_id}\">Перейти к новости</a>".html_safe
    @news_name = news_name
    mail(to: emails, subject: subject, from: ENV['FROM_MAIL'])
  end
end
