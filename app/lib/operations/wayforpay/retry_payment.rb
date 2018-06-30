module Operations
  module Wayforpay
    class RetryPayment
      def initialize(payment_id, card_id)
        @payment_id = payment_id
        @card_id = card_id
      end

      attr_reader :payment_id, :card_id

      def call
        response = retry_pay
        if response['reasonCode'] == Constants::Payments::WAYFORPAY_SUCCESS
          payment.update(status: Constants::Payments::SUCCESS)
        else
          payment.update(response: response)
        end
        response
      end

      private

      def retry_pay
        order_reference = "#{payment.order_reference}_retry_#{SecureRandom.base58(6)}"
        hold = ::Wayforpay::Payments.hold(
          orderReference:  order_reference,
          amount: payment.amount.to_s,
          currency: 'UAH',
          recToken: card.token,
          productName: ['Trip'],
          productPrice: [payment.amount.to_s],
          productCount: [1],
          orderDate: Time.now.to_i,
          merchantTransactionType: 'SALE',
          clientEmail: card.user.email,
          clientPhone: card.user.phone_number
        )
        JSON.parse(hold.body)
      end

      def card
        @card ||= Card.find(card_id)
      end

      def payment
        @payment ||= Payment.find(payment_id)
      end
    end
  end
end
