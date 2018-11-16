require_relative 'boot'
require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Social
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
    config.middleware.insert_before 0, Rack::Cors do
      allow do
        origins '*'
        resource '*',
                 headers: :any,
                 methods: [:get, :post, :put, :patch, :delete],
                 expose: ['Access-Token', 'Client']
      end
    end

    config.i18n.available_locales = [:ru, :en]
    config.i18n.default_locale = :ru

    config.autoload_paths << Rails.root.join('lib')
    config.autoload_paths += %W(#{config.root}/app/models/ckeditor)
    config.eager_load_paths << "#{Rails.root}/lib"
    config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}').to_s]
    config.active_job.queue_adapter = :sidekiq
  end
end
