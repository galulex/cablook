module Jobs
  class PaymentTip < ActiveJob::Base
    queue_as :payments

    def perform(trip_id, amount)
      Operations::Wayforpay::DoPayment.new(trip_id, 'Tip', amount).call
    end
  end
end
