module Operations
  module Fondy
    class DoPayment
      def initialize(trip_id, payment_type, amount)
        @trip_id = trip_id
        @payment_type = payment_type
        @amount = amount
      end

      attr_reader :trip_id, :payment_type, :amount

      def call
        return if payment.status == Constants::Payments::SUCCESS
        types = Constants::Payments::TYPES.except(:order).values
        case payment_type
        when types[1], types[2], types[3]
          update_payment_and_total
        when types[0]
          update_payment_and_total
        end

        charge_driver_card if success_response?
      end

      private

      def charge_driver_card
        { status: 'OK' }
      end

      def update_payment
        status = success_response? ? Constants::Payments::SUCCESS : Constants::Payments::PENDING
        payment.update(
          response: fondy_response,
          status: status,
          amount: amount || payment.amount
        )
      end

      def fondy_response
        @fondy_response ||= ::Fondy::Capture.new(trip.trip_payment.order_reference, amount || trip.cost).call
      end

      def success_response?
        @success_response ||= JSON.parse(fondy_response)['response']['response_status'] == 'success'
      end

      def update_total
        trip.update(total: trip.payments.sum(:amount))
      end

      def card
        trip.trip_payment&.card || trip.user.cards.last
      end

      def update_payment_and_total
        update_payment
        update_total
      end

      def trip
        @trip ||= Trip.find(trip_id)
      end

      def payment
        @payment ||= trip.payments.last
      end
    end
  end
end
