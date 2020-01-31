module Jobs
  class PaymentFakeSettle < ActiveJob::Base
    queue_as :payments

    def perform(trip_id, amount)
      Operations::Wayforpay::DoPayment.new(trip_id, 'FakeTaxi', amount).call
    end
  end
end
