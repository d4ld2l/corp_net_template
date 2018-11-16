class EventMailer < ApplicationMailer
  def send_email(type, email, event)
    @greeting = case type
                when 'create'
                  "Вы приглашены на мероприятие:"
                when 'destroy'
                  "Мероприятие было отменено:"
                else
                  "Произошли изменения в мероприятии:"
                end
    event = HashWithIndifferentAccess.new(event)
    @link = [ENV['FRONT_HOST'], 'calendar', 'events', event[:id]].join('/')
    @title = event[:name]
    @starts_at = Time.parse(event[:starts_at])
    @ends_at = Time.parse(event[:ends_at])
    @place = event[:place]
    @creator = event.dig(:created_by, :full_name)
    @event_type = event.dig(:event_type, :name)
    @changes = event[:changes] || {}
    @previous_event_type = (@changes[:event_type_id]&.present? && @changes[:event_type_id][0]&.present? ? EventType.find(@changes[:event_type_id][0])&.name : nil)
    @type = type
    @event = event
    subject = event[:name]
    mail(to: email, from: ENV['FROM_MAIL'], subject: subject)
  end
end
