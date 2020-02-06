module Operations
  module Wayforpay
    extend self

    def refund(trip_id, fake: nil)
      Operations::Wayforpay::Refund.new(trip_id, fake: fake).call
    end
  end
end
