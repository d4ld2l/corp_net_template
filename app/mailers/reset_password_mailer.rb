class ResetPasswordMailer < ApplicationMailer
  def send_email(account_id)
    @account = Account.find_by(id: account_id)
    subject = "Восстановление пароля"
    mail(to: @account.email, from: ENV['FROM_MAIL'], subject: subject)
  end

  def password_changed_email(account_id)
    @account = Account.find_by(id: account_id)
    subject = "Изменение пароля"
    mail(to: @account.email, from: ENV['FROM_MAIL'], subject: subject)
  end
end
