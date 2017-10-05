class UserMailer < ApplicationMailer
  include ActionView::Helpers::UrlHelper
  include Devise::Controllers::UrlHelpers
  
  def send_email(message, user)
    subject = 'Приглашение на регистрацию'
    full_name = user&.profile&.full_name
    email_with_name = "#{full_name}" + "<#{user.email}>"
    
    user = User.create_new_user_by_invite_email(message)
    
    _link = link_to 'Личном кабинете SHR' ,Rails.application.routes.url_helpers.cfem_url(token: user[:token]['access-token'], client: user[:token]['client'], email: user[:user].email, controller: 'auth/sessions', action: 'create_from_email_message', host: ENV['HOST'])

    @body = "Уважаемый #{user[:user].profile&.full_name}!<br>
             Пользователь #{full_name} приглашает вас зарегистрироваться в #{_link}.<br>
             Логином является адрес электронной почты #{user[:user].email}.<br>
             После регистрации не забудьте сменить пароль.".html_safe

    mail(to: user[:user].email, subject: subject, from: email_with_name) do |format|
      format.html { render 'admin/user_mailer/template' }
    end
  end
end
