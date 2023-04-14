module Jobs
  class PaymentRetry < ActiveJob::Base
    queue_as :retry_payments

    def perform(payment_id, card_id)
      payment = Payment.find(payment_id)
      settings = Settings.get
      return Operations::Wayforpay::RetryPayment.new(payment_id, card_id).call if settings.wayforpay?
      return Operations::Fondy::RetryPayment.new(payment_id, card_id).call if settings.fondy?
    end
  end
end
