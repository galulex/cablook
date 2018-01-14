module Jobs
  class PaymentSettle < ActiveJob::Base
    def perform(trip_id)
      Operations::Wayforpay.settle(trip_id)
    end
  end
end
