module Operations
  module Wayforpay
    class Settle
      def initialize(trip_id)
        @trip_id = trip_id
      end

      attr_reader :trip_id

      # TODO: Impement logic when the price changed
      def call
        wayforpay_response = JSON.parse(settle_payment.body)
        update_payment_status if wayforpay_response['reasonCode'] == '1100'
      end

      private

      def settle_payment
        ::Wayforpay::Payments.settle(
          orderReference: payment.order_reference,
          amount: payment.amount,
          currency: 'UAH'
        )
      end

      def update_payment_status
        payment_repository.update(payment.id, status: Constants::Payments::SUCCESS)
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
