module Operations
  module Wayforpay
    extend self

    def hold(trip_id, card_id)
      Operations::Wayforpay::Hold.new(trip_id: trip_id, card_id: card_id).call
    end

    def settle(trip_id)
      Operations::Wayforpay::Settle.new(trip_id).call
    end

    def refund(trip_id)
      Operations::Wayforpay::Refund.new(trip_id).call
    end
  end
end
