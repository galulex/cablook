module Operations
  module Wayforpay
    class Refund
      def initialize(trip_id)
        @trip_id = trip_id
      end

      attr_reader :trip_id

      def call
        if payment.status == Constants::Payments::BONUS
          refund_bonus
          update_payment_status
        else
          refund_response = JSON.parse(refund_payment.body)
          update_payment_status if refund_response['reasonCode'] == Constants::Payments::WAYFORPAY_SUCCESS
        end
      end

      private

      def refund_payment
        ::Wayforpay::Payments.refund(
          orderReference: payment.order_reference,
          amount: payment.amount,
          currency: 'UAH',
          comment: 'Cancel trip'
        )
      end

      def update_payment_status
        payment_repository.update(payment.id, status: Constants::Payments::REFUND)
      end

      def refund_bonus
        bt_repository = Repositories::BonusTrip.new(ROM.env)
        bonus_trip = bt_repository.by_trip(trip_id)
        bt_repository.update(bonus_trip.id, status: Constants::BonusTrip::NEW) if bonus_trip
      end

      def payment
        @payment ||= payment_repository.by_trip(trip_id)
      end

      def payment_repository
        @payment_repository ||= Repositories::Payment.new(ROM.env)
      end
    end
  end
end
