module Constants
  module BroadcastActions
    DRIVER_SIGN_OUT   = 'DriverSignOut'.freeze
    SEND_LOCATION     = 'SendLocation'.freeze
    SOS               = 'SOS'.freeze
    TRIP_ACCEPTED     = 'TripAccepted'.freeze
    TRIP_PROPOSE      = 'TripPropose'.freeze
    TRIP_UNAVAILABLE  = 'TripUnavailable'.freeze
    TRIP_DECLINED     = 'TripDeclined'.freeze

    TRIP_UPDATED      = 'TripUpdated'.freeze
    TRIP_FINISHED     = 'TripFinished'.freeze
    TRIP_STARTED      = 'TripStarted'.freeze
    TRIP_WAITING      = 'DriverArrived'.freeze

    TRIP_FINISH_ACTION     = 'finish_trip'.freeze
    TRIP_START_ACTION      = 'start_trip'.freeze
    TRIP_WAITING_ACTION    = 'waiting_client'.freeze
  end
end
