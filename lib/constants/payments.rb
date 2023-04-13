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

    TYPES = {
      order: 'Order'.freeze,
      trip: 'Trip'.freeze,
      tip: 'Tip'.freeze,
      idle: 'Idle'.freeze,
      fake: 'FakeTaxi'.freeze
    }.freeze
  end
end
