module Operations
  module Wayforpay
    extend self

    def settle(trip_id)
      Operations::Wayforpay::Settle.new(trip_id).call
    end

    def fake_settle(trip_id)
      Operations::Wayforpay::PaymentFakeSettle(trip_id).call
    end

    def refund(trip_id, fake: nil)
      Operations::Wayforpay::Refund.new(trip_id, fake: fake).call
    end

    def idle(trip_id, amount)
      Operations::Wayforpay::IdleSettle.new(trip_id, amount).call
    end
  end
end
