class ElasticReindexerWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'elasticsearch-social', retry: true


  def perform(*args)
    `RAILS_ENV=#{Rails.env} rails elasticsearch:reindex`
  end
end
