module Constants
  module Trip
    PENDING        = 0
    ON_THE_WAY     = 1
    WAITING_CLIENT = 2
    DRIVING        = 3
    FINISHED       = 4
    CANCELED       = 5

    CENTS_PER_METER = 0.56
    FEE = 0.025
    LANDING = 1_000

    STATUSES = {
      PENDING        => 'pending'.freeze,
      ON_THE_WAY     => 'on_the_way'.freeze,
      WAITING_CLIENT => 'waiting_client'.freeze,
      DRIVING        => 'driving'.freeze,
      FINISHED       => 'finished'.freeze,
      CANCELED       => 'canceled'.freeze
    }.freeze
  end
end
