module Operations
  module Wayforpay
    class Refund
      def initialize(payment_id, fake: nil)
        @payment_id = payment_id
        @fake = fake
      end

      attr_reader :payment_id, :fake

      def call
        if payment.status == Constants::Payments::BONUS
          refund_bonus
          update_payment_status
        elsif payment.status == Constants::Payments::PENDING
          update_payment_status
        else
          refund_response = JSON.parse(refund_payment.body)
          update_payment_status if refund_response['reasonCode'] == Constants::Payments::WAYFORPAY_SUCCESS
        end
      end

      private

      def refund_payment
        hold_for_fake if fake
        ::Wayforpay::Payments.refund(
          orderReference: payment.response["orderReference"] || payment.order_reference,
          amount: payment.amount,
          currency: 'UAH',
          comment: 'Cancel trip'
        )
      end

      def hold_for_fake
        order_reference = "#{payment.order_reference}_fake_#{SecureRandom.base58(6)}"
        card = Card.find(payment.card_id)
        ::Wayforpay::Payments.hold(
          orderReference:  order_reference,
          amount: prices.landing/100,
          currency: 'UAH',
          recToken: card.token,
          productName: ['Trip'],
          productPrice: [prices.landing/100],
          productCount: [1],
          orderDate: Time.now.to_i,
          merchantTransactionType: 'SALE'
        )
      end

      def prices
        @prices ||= Price.last
      end

      def update_payment_status
        payment.update(status: Constants::Payments::REFUND)
      end

      def refund_bonus
        bonus_trip = BonusTrip.find_by(trip_id: payment.trip_id)
        bonus_trip&.fresh!
      end

      def payment
        @payment ||= Payment.find(payment_id)
      end
    end
  end
end
