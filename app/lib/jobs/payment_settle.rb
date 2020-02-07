module Jobs
  class PaymentSettle < ActiveJob::Base
    queue_as :payments

    def perform(trip_id, payment_type, amount = nil)
      Operations::Wayforpay::DoPayment.new(trip_id, payment_type, amount).call
    end
  end
end
