module Operations
  module Wayforpay
    class RetryPayment
      def initialize(payment_id, card_id)
        @payment_id = payment_id
        @card_id = card_id
      end

      attr_reader :payment_id, :card_id

      def call
        return unless card
        if retry_response['reasonCode'] == Constants::Payments::WAYFORPAY_SUCCESS
          payment.update(status: Constants::Payments::SUCCESS, response: retry_response)
        else
          payment.update(response: retry_response)
        end
        retry_response
      end

      private

      def retry_response
        order_reference = "#{payment.order_reference}_retry_#{SecureRandom.base58(6)}"
        @retry_response ||= Operations::Wayforpay::SendPayment.new(card, payment.amount, payment.type, order_reference).call
      end

      def card
        return unless card_id
        @card ||= Card.find(card_id)
      end

      def payment
        @payment ||= Payment.find(payment_id)
      end
    end
  end
end
