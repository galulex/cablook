module Operations
  module Wayforpay
    class RefundForOrder
      def initialize(payment_id)
        @payment_id = payment_id
      end

      attr_reader :payment_id

      def call
        refund_response = JSON.parse(refund_payment.body)
        update_payment_status if refund_response['reasonCode'] == Constants::Payments::WAYFORPAY_SUCCESS
      end

      private

      def refund_payment
        ::Wayforpay::Payments.refund(
          orderReference: payment.response["orderReference"] || payment.order_reference,
          amount: payment.amount,
          currency: 'UAH',
          comment: 'Refund order'
        )
      end

      def update_payment_status
        payment.update(status: Constants::Payments::REFUND)
      end

      def payment
        @payment ||= Payment.find(payment_id)
      end
    end
  end
end

