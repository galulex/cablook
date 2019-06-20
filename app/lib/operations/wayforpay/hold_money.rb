module Operations
  module Wayforpay
    class HoldMoney
      def initialize(card, amount, order_reference)
        @card = card
        @amount = amount
        @product_name = 'Delivery'
        @order_reference = order_reference
      end

      attr_reader :card, :amount, :product_name, :order_reference

      def call
        hold = ::Wayforpay::Payments.hold(
          recToken: card.token,
          amount: amount,
          currency: 'UAH',
          productName: [product_name],
          productPrice: [amount.to_s],
          productCount: [1],
          orderDate: Time.now.to_i,
          merchantTransactionType: 'AUTH',
          orderReference: order_reference,
          clientEmail: card.user.email,
          clientPhone: card.user.phone_number
        )
        JSON.parse(hold.body)
      end
    end
  end
end
