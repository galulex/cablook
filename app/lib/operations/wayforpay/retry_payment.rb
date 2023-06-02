module Operations
  module Wayforpay
    class RetryPayment
      RETRY_SUFIX = '_retry'.freeze

      def initialize(payment_id, card_id)
        @payment_id = payment_id
        @card_id = card_id
      end

      attr_reader :payment_id, :card_id

      def call
        return unless card_id && card && card.payment_system == Settings.payment_system['wayforpay']
        if retry_response['reasonCode'] == Constants::Payments::WAYFORPAY_SUCCESS
          payment.update(status: Constants::Payments::SUCCESS, response: retry_response)
          add_cashback if payment.type == 'Payments::Trip'
        else
          payment.update(response: retry_response)
        end
        retry_response
      end

      private

      def retry_response
        @retry_response ||= Operations::Wayforpay::SendPayment.new(card, payment.amount, payment.type, order_reference).call
      end

      def add_cashback
        return unless Settings.cashback
        user.update(cashback: user.cashback + cashback_amount)
      end

      def cashback_amount
        payment.amount * 0.05 * 100
      end

      def order_reference
        @order_reference ||= OrderReference.new(payment.trip_id, payment.type.demodulize.downcase).call.concat(RETRY_SUFIX)
      end

      def card
        @card ||= Card.find(card_id)
      end

      def payment
        @payment ||= Payment.find(payment_id)
      end

      def user
        @user ||= payment.user
      end
    end
  end
end
