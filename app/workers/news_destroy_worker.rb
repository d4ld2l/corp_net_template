class NewsDestroyWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'default', retry: true

  def perform(*args)
    NewsCategory.where(name: 'Новые коллеги').or(NewsCategory.where(name: 'День рождения')).map{|x| x.news_items.where('created_at < (?)', Date.current - 7.days).where(state: :published).each(&:to_unpublished!)}
  end
end
