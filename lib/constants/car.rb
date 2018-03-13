module Constants
  module Car
    OFFLINE        = 0
    FREE           = 1
    DURING_IN_TRIP = 2
    CHARGE         = 3

    STATUS_CODES = {
      OFFLINE        => 'offline'.freeze,
      FREE           => 'free'.freeze,
      DURING_IN_TRIP => 'during_in_trip'.freeze,
      CHARGE         => 'charge'.freeze
    }.freeze
  end
end
