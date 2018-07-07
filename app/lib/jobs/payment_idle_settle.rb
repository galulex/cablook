module Jobs
    class PaymentIdleSettle < ActiveJob::Base
      queue_as :payments
  
      def perform(trip_id, idle)
        Operations::Wayforpay.idle_settle(trip_id, idle)
      end
    end
  end