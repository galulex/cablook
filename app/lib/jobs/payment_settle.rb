module Jobs
  class PaymentSettle < ActiveJob::Base
    queue_as :payments

    def perform(trip_id)
      Operations::Wayforpay.settle(trip_id)
    end
  end
end
