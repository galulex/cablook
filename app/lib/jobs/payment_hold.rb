module Jobs
  class PaymentHold < ActiveJob::Base
    queue_as :payments

    def perform(trip_id, card_id)
      Operations::Wayforpay.hold(trip_id, card_id)
    end
  end
end
