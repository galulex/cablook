require_relative 'boot'

require 'rails'
# Pick the frameworks you want:
require 'active_job/railtie'
require 'action_controller/railtie'
require 'action_mailer/railtie'
require 'action_cable/engine'
require 'active_record/railtie'
require 'active_model/railtie'
require 'sprockets/railtie'
require 'sprockets/es6'


Bundler.require(*Rails.groups)

module CabLook
  class Application < Rails::Application
    config.load_defaults 5.1

    config.autoload_paths << "#{config.root}/lib"
    config.autoload_paths << "#{config.root}/app/models"
    config.autoload_paths << "#{config.root}/app/channels"
    config.eager_load_paths << "#{Rails.root}/lib"

    config.active_job.queue_adapter = :sidekiq
    config.assets.precompile += %w( fonts.css )

    if File.exist?('config/secrets.yml')
      YAML.safe_load(File.read('config/secrets.yml'))[Rails.env].each do |key, value|
        ENV[key.upcase] = value unless ENV[key.upcase]
      end
    end

    config.i18n.default_locale = :ua
    config.i18n.fallbacks = true
    config.i18n.fallbacks = [:en]
  end
end
