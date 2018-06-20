module Jobs
  class PaymentRefundDeclined < ActiveJob::Base
    queue_as :payments

    def perform(trip_id)
      trip = Trip.find(trip_id)
      return unless trip.status == Constants::Trip::STATUS_CODES[Constants::Trip::DECLINED]
      Operations::Wayforpay.refund(trip_id)
    end
  end
end
