class PersonalNotificationsDestroyWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'default', retry: true

  def perform(*args)
    PersonalNotification.where(read: true).where('created_at < (?)', Date.current - 1.month).destroy_all
  end
end
