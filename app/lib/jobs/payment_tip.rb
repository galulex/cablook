module Jobs
  class PaymentTip < ActiveJob::Base
    queue_as :payments

    def perform(trip_id, amount)
      Operations::TipForTrip.new(trip_id, amount).call
    end
  end
end
