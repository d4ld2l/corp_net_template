class BidMailer < ApplicationMailer
  default from: ENV['FROM_MAIL'] || 'noreply@example.com'

  attr_accessor :letter

  def notification_about_change_state(bid, emails)
    generate_letter(bid)
    @body = @letter[:body]
    @emails = emails || []

    mail bcc: emails, subject: @letter[:subject] do |format|
      format.html { render 'template' }
    end
  end

  private

  def params(bid)
    {
      id: bid.id,
      service_name: bid.service&.name,
      created_at: I18n.l(bid.created_at, format: :with_and),
      state: bid&.bid_stage&.name
    }
  end

  def generate_letter(bid)
    @letter = {}
    all_change_state(params(bid))
  end

  def all_change_state(bid)
    @letter[:subject] = "заявка №#{bid[:id]}"
    @letter[:body]    = "Заявка №#{bid[:id]} переведена в статус «#{bid[:state]}». Сервис: #{bid[:service_name]}. Заявка создана #{bid[:created_at]}"
  end
end
