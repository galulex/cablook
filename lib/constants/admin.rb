module Constants
  module Admin
    USER_MODIFIED_COLUMNS = %w[bonus_count].freeze
    USER_EXCLUDED_COLUMNS = %w[
      notification_settings
      auth_token
    ].freeze

    GENERAL_SETTINGS_COLUMNS = %w[payment_system address_geocoder before_create_trip_message on_app_start_message].freeze
    SETTINGS_TITLE = 'Settings'.freeze
    FEATURES_TITLE = 'Features'.freeze
    GENERAL_TITLE = 'General'.freeze

    BONUS_TRIP_COLUMNS = %w[id user friend trip status type].freeze
    DRIVER_COLUMNS = %w[name username balance password auth_token address active car card_number inn].freeze
  end
end
