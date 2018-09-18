module Jobs
  class PaymentRetry < ActiveJob::Base
    queue_as :retry_payments

    def perform(payment_id, card_id, with_sms)
      sms_text = I18n.t('verifications.number.send_retry_message')
      payment = Payment.find(payment_id)
      response = Operations::Wayforpay::RetryPayment.new(payment_id, card_id).call
      Jobs::Sms.perform_later(payment.user.phone_number, sms_text) if with_sms == true && response['reasonCode'] != 1100
    end
  end
end
