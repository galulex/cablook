require_relative 'boot'

require 'rails'
# Pick the frameworks you want:
require 'active_job/railtie'
require 'action_controller/railtie'
require 'action_mailer/railtie'
require 'action_cable/engine'

require_relative '../lib/events'

Bundler.require(*Rails.groups)

module CabLook
  class Application < Rails::Application
    config.load_defaults 5.1

    config.api_only = true
  end
end
