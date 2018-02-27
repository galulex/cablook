module Jobs
  class PaymentRefund < ActiveJob::Base
    queue_as :payments

    def perform(trip_id, fake = nil)
      Operations::Wayforpay.refund(trip_id, fake: fake)
    end
  end
end
