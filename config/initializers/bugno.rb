# frozen_string_literal: true

Bugno.configure do |config|
  # Specify api key to send exception to Bugno
  config.api_key = 'UAQmtJvMXq3AUTyJCQZ6mS7E'

  # Send in background with threading:
  config.send_in_background = true

  # Skip rails related exceptions:
  config.exclude_rails_exceptions = true

  # Specify which rails exception to skip:
  config.excluded_exceptions = ['ActionController::RoutingError']

  # Specify or add usage environments:
  config.usage_environments = %w[production]
  # config.usage_environments << 'development'

  # Specify current user method:
  config.current_user_method = 'current_user'

  # Add scrub fields and headers:
  config.scrub_fields << 'authenticity_token'
  # config.scrub_headers << 'access_token'
end
