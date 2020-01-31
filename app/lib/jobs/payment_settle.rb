module Jobs
  class PaymentSettle < ActiveJob::Base
    queue_as :payments

    def perform(trip_id)
      Operations::Wayforpay::DoPayment.new(trip_id, 'Trip').call
    end
  end
end
