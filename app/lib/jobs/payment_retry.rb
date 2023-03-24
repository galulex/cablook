module Jobs
  class PaymentRetry < ActiveJob::Base
    queue_as :retry_payments

    def perform(payment_id)
      payment = Payment.find(payment_id)
      Operations::Fondy::DoPayment.new(payment.trip_id, payment.type, payment.amount).call
    end
  end
end
