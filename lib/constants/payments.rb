module Constants
  module Payments
    PENDING = 0
    DECLINE = 1
    SUCCESS = 2
    REFUND  = 3
    BONUS   = 4
    HOLD    = 5

    WAYFORPAY_SUCCESS = 1100
    FONDY_SUCCESS = 'success'.freeze
    FONDY_APPROVED = 'approved'.freeze
    FONDY_CAPTURED = 'captured'.freeze
    FONDY_REVERSED = 'reversed'.freeze

    TYPES = {
      order: 'Order'.freeze,
      trip: 'Trip'.freeze,
      tip: 'Tip'.freeze,
      idle: 'Idle'.freeze,
      fake: 'FakeTaxi'.freeze,
      payout: 'PayOut'.freeze
    }.freeze

    TRIP = 'Payments::Trip'.freeze
    TIP = 'Payments::Tip'.freeze
    IDLE = 'Payments::Idle'.freeze
    FAKE = 'Payments::FakeTaxi'.freeze
    PAYOUT = 'Payments::PayOut'.freeze

    OPTIONAL_PAYMENTS = [TIP, PAYOUT].freeze
    DRIVER_STATISTIC_ENTRIES = [TRIP,TIP,IDLE,FAKE].freeze
  end
end
