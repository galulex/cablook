module Operations
  module Wayforpay
    class SettleHoldedMoney
      def initialize(order)
        @order = order
      end

      attr_reader :order

      def call
        settle = ::Wayforpay::Payments.settle(
          amount: @order.payment.response['amount'],
          currency: 'UAH',
          merchantTransactionType: 'SETTLE',
          orderReference: @order.payment.response['orderReference'],
        )
        JSON.parse(settle.body)
      end
    end
  end
end
