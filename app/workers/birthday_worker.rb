class BirthdayWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'default', retry: true

  def perform(*args)
    profiles = Profile.where("extract(day from birthday) = ? and extract(month from birthday) = ?", Date.current.day, Date.current.month).order(:surname, :name, :middlename)
    return if profiles.blank?
    view = ActionView::Base.new(Rails.root.join('app/views'))
    view.class.include ApplicationHelper
    NewsCategory.find_or_create_by(name: 'День рождения').news_items.create(state: 'published', published_at: DateTime.now, title: 'Поздравьте коллег', body: view.render(
        partial: 'news/birthday',
        locals: {profiles: profiles},
        layout: false
    ).html_safe)
  end
end
