module Constants
  module User
    NOTIFICATIONS = %w[accept_trip decline_trip waiting_client].freeze
    ACCEPT_TRIP = 'accept_trip'.freeze
    DECLINE_TRIP = 'decline_trip'.freeze
    WAITING_CLIENT = 'waiting_client'.freeze
    LOCALE_CODES = {
      0 => 'uk'.freeze,
      1 => 'en'.freeze,
      2 => 'ru'.freeze
    }.freeze
  end
end
