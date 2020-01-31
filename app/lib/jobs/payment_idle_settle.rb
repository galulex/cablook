module Jobs
  class PaymentIdleSettle < ActiveJob::Base
    queue_as :payments

    def perform(trip_id, idle)
      Operations::Wayforpay::DoPayment.new(trip_id, 'Idle', idle).call
    end
  end
end
