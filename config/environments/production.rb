Rails.application.configure do
  config.action_cable.url = 'ws://cablook.herokuapp.com/cable'
  config.action_cable.allowed_request_origins = [
    'https://cablook.herokuapp.com',
    'http://cablook.herokuapp.com',
    'https://staging.cablook.taxi',
    'https://cablook.taxi'
  ]

  config.secret_key_base = ENV['SECRET_KEY_BASE'] unless config.secret_key_base

  config.cache_classes = true

  config.eager_load = true

  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  config.read_encrypted_secrets = true

  config.public_file_server.enabled = ENV['RAILS_SERVE_STATIC_FILES'].present?

  # Mount Action Cable outside main process or domain
  # config.action_cable.mount_path = nil
  # config.action_cable.url = 'wss://example.com/cable'
  # config.action_cable.allowed_request_origins = [ 'http://example.com', /http:\/\/example.*/ ]

  config.log_level = :debug

  # Prepend all log lines with the following tags.
  config.log_tags = [:request_id]

  # Use a real queuing backend for Active Job (and separate queues per environment)
  # config.active_job.queue_adapter     = :resque
  # config.active_job.queue_name_prefix = "cablook_#{Rails.env}"
  config.action_mailer.perform_caching = false

  # Mailer configuration for mailgun smtp
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.perform_deliveries = true
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.smtp_settings = {
    authentication:       :plain,
    address:              'smtp.mailgun.org',
    port:                 587,
    domain:               'cablook.taxi',
    user_name:            ENV['MAILGUN_EMAIL'],
    password:             ENV['MAILGUN_PASSWORD'],
    enable_starttls_auto: true
  }

  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners.
  config.active_support.deprecation = :notify

  # Use default logging formatter so that PID and timestamp are not suppressed.
  config.log_formatter = ::Logger::Formatter.new

  if ENV['RAILS_LOG_TO_STDOUT'].present?
    logger           = ActiveSupport::Logger.new(STDOUT)
    logger.formatter = config.log_formatter
    config.logger    = ActiveSupport::TaggedLogging.new(logger)
  end
end
