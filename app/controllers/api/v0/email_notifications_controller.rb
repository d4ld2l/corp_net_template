class Api::V0::EmailNotificationsController < Api::BaseController
  before_action :authenticate_account!

  def create
    begin
      send_email_from_params(notification_params)
    rescue ArgumentError => e
      render json: {success: false, error: e.message}
    else
      render json: {success: true}
    end
  end

  private

  def send_email_from_params(params)
    to = params.delete(:to)
    copy = params.delete(:copy)
    subject = params.delete(:subject)
    body = params.delete(:body)
    raise ArgumentError, 'empty list of destinations' if to.blank?
    raise ArgumentError, 'empty body' if body.blank?
    raise ArgumentError, 'empty subject' if subject.blank?
    ManualNotificationsMailer.send_email(to, copy, subject, body).deliver_later
  end

  def notification_params
    params.require(:email_notification).permit(:subject, :body, to: [], copy: [])
  end
end
