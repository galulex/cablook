module Operations
  module Wayforpay
    extend self

    def refund(trip_id, fake: nil)
      return unless Settings.get.wayforpay?
      Operations::Wayforpay::Refund.new(trip_id, fake: fake).call
    end
  end
end
