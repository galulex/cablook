module Jobs
  class PaymentRefundDeclined < ActiveJob::Base
    queue_as :payments

    def perform(trip_id)
      trip = Repositories::Trip.new(ROM.env).by_id(trip_id)
      return unless trip.status == Constants::Trip::DECLINED
      Operations::Wayforpay.refund(trip_id)
    end
  end
end
