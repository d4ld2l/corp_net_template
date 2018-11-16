# This file is used by Rack-based servers to start the application.

require_relative 'config/environment'

if ENV['REDIS_URL']
  require 'rack'
  require 'rack/cache'
  require 'redis-rack-cache'

  use Rack::Cache,
      metastore: "#{ENV['REDIS_URL']}/0/metastore_#{ENV['RAILS_ENV'] || 'development'}",
      entitystore: "#{ENV['REDIS_URL']}/0/entitystore_#{ENV['RAILS_ENV'] || 'development'}"
end

run Rails.application
