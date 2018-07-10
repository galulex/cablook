module Jobs
  class PaymentIdleSettle < ActiveJob::Base
    queue_as :payments

    def perform(trip_id, idle)
      Operations::Wayforpay.idle(trip_id, idle)
    end
  end
end
