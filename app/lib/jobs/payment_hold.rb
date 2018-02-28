module Jobs
  class PaymentHold < ActiveJob::Base
    queue_as :payments

    def perform(trip_id, card_id)
      Operations::Wayforpay.hold(trip_id, card_id)
      trip = Repositories::Trip.new(ROM.env).by_id(trip_id)
      if trip.status == Constants::Trip::CANCELED
        Operations::Wayforpay.refund(trip_id)
      end
    end
  end
end
