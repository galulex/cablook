module Operations
  module Fondy
    class DriverPayOut < Base
      def initialize(payment_id)
        @payment_id = payment_id
      end

      attr_reader :payment_id

      def call
        payout_driver
      end

      private

      def payout_driver
        Payment.create(
          trip_id: payment.trip.id,
          user_id: payment.user.id,
          card_id: payment.card&.id,
          type: Constants::Payments::PAYOUT,
          response: payout_response,
          status: pay_out_status,
          amount: payment.amount,
          order_reference: payout_response[:order_id]
        )
      end

      def pay_out_status
        payout_response[:status] ? Constants::Payments::SUCCESS : Constants::Payments::PENDING
      end

      def payout_response
        @payout_response ||= ::Fondy::ChargeCard.new(payment).call
      end

      def payment
        @payment ||= Payment.find(payment_id)
      end
    end
  end
end
