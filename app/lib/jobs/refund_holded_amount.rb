module Jobs
  class RefundHoldedAmount < ActiveJob::Base
    def perform(trip_id, amount, order_reference)
      trip = Trip.find(trip_id)
      payment = trip.trip_payment
      return if trip.status != Constants::Trip::STATUS_CODES[Constants::Trip::DECLINED] || payment.response['reverse_status'] == Constants::Payments::FONDY_APPROVED

      reverse_response = Fondy::Reverse.new(amount, order_reference).call
      payment.update!(response: payment.response.merge(reverse_response))
    end
  end
end
