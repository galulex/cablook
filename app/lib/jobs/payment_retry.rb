module Jobs
  class PaymentRetry < ActiveJob::Base
    queue_as :retry_payments

    def perform(payment_id, card_id)
      payment = Payment.find(payment_id)
      Operations::Payments::RetryPayment.new(payment_id, card_id).call
    end
  end
end
