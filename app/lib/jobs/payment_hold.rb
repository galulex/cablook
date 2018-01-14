module Jobs
  class PaymentHold < ActiveJob::Base
    def perform(trip_id, card_id)
      Operations::Wayforpay.hold(trip_id, card_id)
    end
  end
end
