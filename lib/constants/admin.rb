module Constants
  module Admin
    USER_MODIFIED_COLUMNS = %w[bonus_count].freeze
    USER_EXCLUDED_COLUMNS = %w[
      notification_settings
      encrypted_password
      auth_token
      confirmation_token
      verification_token
    ].freeze
  end
end
