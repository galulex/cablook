module Operations
  module Wayforpay
    class IdleSettle
      def initialize(trip_id, idle)
        @trip_id = trip_id
        @idle = idle
      end

      attr_reader :trip_id, :idle

      def call
        status = Constants::Payments::PENDING
        if settle_idle_response['reasonCode'] == Constants::Payments::WAYFORPAY_SUCCESS
          status = Constants::Payments::SUCCESS
          update_trip_total_and_idle
        end
        create_idle_payment(status)
      end

      private

      def settle_idle_response
        @settle_idle_response ||= Operations::Wayforpay::SendPayment.new(card, idle_amount, 'Idle', order_reference).call
      end

      def create_idle_payment(status)
        Payments::Idle.create(
          trip_id: trip_id,
          user_id: trip.user_id,
          amount: idle_amount,
          response: settle_idle_response,
          status: status,
          order_reference: order_reference
        )
      end

      def prices
        @prices ||= Price.last
      end

      def idle_amount
        @idle_amount ||= idle / 60 * prices.idle_price
      end

      def update_trip_total_and_idle
        trip.update(idle: idle, total: trip.trip_payment.amount.to_i + idle_amount.to_i)
      end

      def trip
        @trip ||= Trip.find(trip_id)
      end

      def card
        trip.trip_payment.card || Card.where(user: trip.user_id).last
      end

      def payment
        @payment ||= Payment.find_by(trip_id: trip_id)
      end

      def order_reference
        @order_reference ||= "#{payment.order_reference}_idle_#{SecureRandom.base58(6)}"
      end
    end
  end
end
