module Constants
  module Payments
    PENDING = 0
    DECLINE = 1
    SUCCESS = 2
    REFUND  = 3
    BONUS   = 4
    HOLD    = 5

    WAYFORPAY_SUCCESS = 1100

    TYPES = {
      order: 'order'.freeze,
      trip: 'trip'.freeze,
      tip: 'tip'.freeze,
      idle: 'idle'.freeze,
      fake: 'fake_settle'.freeze
    }.freeze
  end
end
