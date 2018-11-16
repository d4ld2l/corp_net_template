# Be sure to restart your server when you modify this file.

if ENV['REDIS_URL']
  Rails.application.config.session_store :redis_store, key: '_social_session_new_api_devise', servers: ["#{ENV['REDIS_URL']}/0/session"]
else
  Rails.application.config.session_store :cookie_store, key: '_social_session_new_api_devise'
end
