namespace :elasticsearch do
  desc 'Reindexes elastic'
  task reindex: :environment do
    Rails.application.eager_load!
    ActiveRecord::Base.descendants.each do |d|
      next unless d.respond_to? :__elasticsearch__
      p d.index_name
      d.__elasticsearch__.delete_index! if d.__elasticsearch__.client.indices.exists?(index: d.index_name)
      d.__elasticsearch__.create_index!
      d.import(force: true)
      p 'done'
    end
  end
end