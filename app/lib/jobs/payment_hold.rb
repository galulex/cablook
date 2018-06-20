module Jobs
  class PaymentHold < ActiveJob::Base
    queue_as :payments

    def perform(trip_id, card_id)
      Operations::Wayforpay.hold(trip_id, card_id)
      trip = Trip.find(trip_id)
      if trip.status == Constants::Trip::STATUS_CODES[Constants::Trip::CANCELED]
        Operations::Wayforpay.refund(trip_id)
      end
    end
  end
end
