module Jobs
  class PaymentRefund < ActiveJob::Base
    def perform(trip_id)
      Operations::Wayforpay.refund(trip_id)
    end
  end
end
