module Constants
  module Trip
    PENDING                    = 0
    ON_THE_WAY                 = 1
    WAITING_CLIENT             = 2
    DRIVING                    = 3
    FINISHED                   = 4
    CANCELED                   = 5
    DECLINED                   = 6
    CANCELED_BY_DRIVER         = 7
    WAITING_FOR_VENDOR_APPROVE = 8

    STATUSES = [PENDING, ON_THE_WAY, WAITING_CLIENT, DRIVING, FINISHED, CANCELED, DECLINED, WAITING_FOR_VENDOR_APPROVE].freeze
    CURRENT_TRIP_STATUSES = [ON_THE_WAY, WAITING_CLIENT, PENDING].freeze

    FEE = 0.025
    MAX_DISTANCE = 60_000
    MAX_BONUS_DISTANCE = 10_000
    FREE_IDLE_VALUE = 5.minutes.to_i

    EXPIRES_IN = 70.seconds.freeze

    STATUS_CODES =  {
      PENDING                    => 'pending'.freeze,
      ON_THE_WAY                 => 'on_the_way'.freeze,
      WAITING_CLIENT             => 'waiting_client'.freeze,
      DRIVING                    => 'driving'.freeze,
      FINISHED                   => 'finished'.freeze,
      CANCELED                   => 'canceled'.freeze,
      DECLINED                   => 'declined'.freeze,
      CANCELED_BY_DRIVER         => 'canceled_by_driver'.freeze,
      WAITING_FOR_VENDOR_APPROVE => 'waiting_for_vendor_approve'.freeze
    }.freeze
  end
end
