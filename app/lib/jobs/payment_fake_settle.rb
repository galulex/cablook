module Jobs
  class PaymentFakeSettle < ActiveJob::Base
    queue_as :payments

    def perform(trip_id)
      Operations::Wayforpay.fake_settle(trip_id)
    end
  end
end
