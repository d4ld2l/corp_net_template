source 'https://rubygems.org'
ruby '2.5.1'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?('/')
  "https://github.com/#{repo_name}.git"
end

# core
gem 'dotenv-rails'
gem 'jbuilder', '~> 2.5'
gem 'pg'
gem 'puma', '~> 3.0'
gem 'rails', '~> 5.2.0'
#gem 'turbolinks', '~> 5'
gem 'draper'
gem 'acts_as_tenant'
gem 'bootsnap', require: false



# front
gem 'bootstrap-sass'
gem 'momentjs-rails', '>= 2.9.0'
gem 'bootstrap3-datetimepicker-rails', '~> 4.17.47'
gem 'coffee-rails', '~> 4.2'
gem 'jquery-rails'
gem 'jquery-ui-rails'
gem 'sass-rails', '~> 5.0'
gem 'slim', '3.0.7'
gem 'uglifier', '>= 1.3.0'
source 'https://rails-assets.org' do
  gem 'rails-assets-tether', '>= 1.3.3'
end
gem 'font-awesome-rails'
gem 'simple_form'
gem 'kaminari'
gem 'ckeditor', github: 'galetahub/ckeditor'
gem 'bootstrap_colorpicker_rails'
gem 'chartkick'
gem 'bootstrap-select-wrapper-rails', github: 'Melpan/bootstrap-select-wrapper-rails'
gem 'dotiw'
gem 'chart-js-rails'
# misc
gem 'carrierwave', '~> 1.0'
gem 'carrierwave-base64'
gem 'file_validators'
gem 'sprockets-rails', :require => 'sprockets/railtie'
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
gem 'rack-cors'
gem 'aasm'
gem 'acts-as-taggable-on'
gem 'mini_magick'
gem 'cocoon'
gem 'gon'
gem 'russian'
gem 'paper_trail'
gem 'migration_data'
gem 'acts_as_list'
gem 'request_store'
gem 'ruby-kafka'
gem 'bunny', '>= 2.9.2'
gem 'counter_culture', '~> 2.0'

#parsing
gem 'docx', '~> 0.2.07', :require => ['docx']
gem 'msworddoc-extractor', github: 'dayflower/msworddoc-extractor'
gem 'antiword', github: 'yagudaev/ruby-antiword'
gem 'libreconv'
gem 'pdf-reader'
gem 'rubyXL', '~> 3.3.26'
gem 'simple_xlsx_reader'
gem 'rubyzip'

#LDAP Server Simulation for RocketChat
gem 'ruby-ldapserver', github: 'inscitiv/ruby-ldapserver'

#auth
gem 'devise'
gem 'devise_token_auth', github: 'Scumfunk/devise_token_auth'
#gem 'simple_token_authentication', '~> 1.0'
gem 'omniauth'
gem 'cancancan', '~> 1.16'
gem 'ahoy_matey'

#elasticsearch
gem 'typeahead-rails'
gem 'elasticsearch-model'
gem 'elasticsearch-rails'

# dev / test
group :development,:development, :test do
  gem 'byebug', platform: :mri
  gem 'pry-byebug'
  gem 'rspec-rails', '~> 3.5'
  gem 'factory_bot_rails'
  gem 'seedbank'
  gem 'faker'
end


group :development, :development_stand do
  gem 'capistrano-rails'
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '~> 3.0.5'
  gem 'letter_opener'
  # gem 'spring'
  # gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'bullet'
  gem 'seed_dump'
end

group :test do
  gem 'sqlite3'
  gem 'database_cleaner'
  gem 'simplecov', :require => false
end

group :development_stand, :production do
  gem 'airbrake', '~> 5.0'
end

gem 'redis-rails'
gem 'redis-rack-cache'
gem 'sidekiq'
gem 'sidekiq-cron', '~> 0.6.3'
gem 'sidekiq-grouping'
gem 'sidekiq-limit_fetch'

gem 'docx_replace'
gem 'ru_propisju'

gem 'sablon'

group :development do
  gem "rails-erd"
end

gem 'gruff'
