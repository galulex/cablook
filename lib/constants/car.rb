module Constants
  module Car
    OFFLINE        = 0
    FREE           = 1
    DURING_TRIP    = 2
    CHARGE         = 3

    STATUS_CODES = {
      OFFLINE        => 'offline'.freeze,
      FREE           => 'free'.freeze,
      DURING_TRIP    => 'during_trip'.freeze,
      CHARGE         => 'charge'.freeze
    }.freeze

    COLORS = %i[black blue red silver white]
    MAX_SPEED = 60
  end
end
