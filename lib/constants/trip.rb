module Constants
  module Trip
    PENDING        = 0
    ON_THE_WAY     = 1
    WAITING_CLIENT = 2
    DRIVING        = 3
    FINISHED       = 4
    CANCELED       = 5
    DECLINED       = 6

    CENTS_PER_KM = 560
    FEE = 0.025
    LANDING = 1_000

    EXPIRES_IN = 1.minute.freeze

    STATUSES = {
      PENDING        => 'pending'.freeze,
      ON_THE_WAY     => 'on_the_way'.freeze,
      WAITING_CLIENT => 'waiting_client'.freeze,
      DRIVING        => 'driving'.freeze,
      FINISHED       => 'finished'.freeze,
      CANCELED       => 'canceled'.freeze,
      DECLINED       => 'declined'.freeze
    }.freeze
  end
end
