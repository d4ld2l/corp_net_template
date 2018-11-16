class NewEmployeeWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'default', retry: true

  def perform(*args)
    profiles = Profile.where(created_at: Date.yesterday.beginning_of_day..Date.yesterday.end_of_day).order(:surname, :name, :middlename)
    return if profiles.blank?
    view = ActionView::Base.new(Rails.root.join('app/views'))
    view.class.include ApplicationHelper
    NewsCategory.find_or_create_by(name: 'Новые коллеги').news_items.create(state: 'published', published_at: DateTime.now, title: 'Добро пожаловать!', body: view.render(
        partial: 'news/employee',
        locals: {profiles: profiles},
        layout: false
    ).html_safe)
  end
end
