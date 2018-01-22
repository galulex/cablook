module Jobs
  class PaymentRefund < ActiveJob::Base
    queue_as :payments

    def perform(trip_id)
      Operations::Wayforpay.refund(trip_id)
    end
  end
end
