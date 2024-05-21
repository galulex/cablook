class Presenters::Settings::UserPublic < Presenters::BaseSingle
  properties :bonuses, :cashback, :delivery, :validate_unpaid_trips, :payment_system, :before_create_trip_message, :email_auth, :cash, :on_app_start_message
end
