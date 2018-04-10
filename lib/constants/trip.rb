module Constants
  module Trip
    PENDING            = 0
    ON_THE_WAY         = 1
    WAITING_CLIENT     = 2
    DRIVING            = 3
    FINISHED           = 4
    CANCELED           = 5
    DECLINED           = 6
    CANCELED_BY_DRIVER = 7

    STATUSES = [PENDING, ON_THE_WAY, WAITING_CLIENT, DRIVING, FINISHED, CANCELED, DECLINED].freeze

    CENTS_PER_KM = 600
    OUTSIDE_CENTS_PER_KM = 900
    FEE = 0.025
    LANDING = 2_000
    MIN_PRICE = 4_000
    MAX_DISTANCE = 40_000
    MAX_BONUS_DISTANCE = 10_000
    FAKE = 20

    EXPIRES_IN = 2.minutes.freeze

    STATUS_CODES = {
      PENDING            => 'pending'.freeze,
      ON_THE_WAY         => 'on_the_way'.freeze,
      WAITING_CLIENT     => 'waiting_client'.freeze,
      DRIVING            => 'driving'.freeze,
      FINISHED           => 'finished'.freeze,
      CANCELED           => 'canceled'.freeze,
      DECLINED           => 'declined'.freeze,
      CANCELED_BY_DRIVER => 'canceled_by_driver'.freeze
    }.freeze
  end
end
