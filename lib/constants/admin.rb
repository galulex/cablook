module Constants
  module Admin
    USER_MODIFIED_COLUMNS = %w[bonus_count].freeze
    USER_EXCLUDED_COLUMNS = %w[
      notification_settings
      auth_token
    ].freeze
  end
end
