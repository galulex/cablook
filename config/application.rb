require_relative 'boot'

require 'rails'
# Pick the frameworks you want:
require 'active_job/railtie'
require 'action_controller/railtie'
require 'action_mailer/railtie'
require 'action_cable/engine'

Bundler.require(*Rails.groups)

module CabLook
  class Application < Rails::Application
    config.load_defaults 5.1

    config.api_only = true

    config.autoload_paths << Rails.root.join('lib')

    config.active_job.queue_adapter = :sidekiq

    if File.exist?('config/secrets.yml')
      YAML.safe_load(File.read('config/secrets.yml'))[Rails.env].each do |key, value|
        ENV[key.upcase] = value unless ENV[key.upcase]
      end
    end
  end
end
