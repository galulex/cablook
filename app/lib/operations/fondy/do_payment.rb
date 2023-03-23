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

        update_payment
        update_total
        charge_driver_card if success_response?
      end

      private

      def payment_attributes
        {
          trip_id: trip_id,
          user_id: trip.user_id,
          card_id: card.id,
          type: "Payments::#{payment_type}"
        }
      end

      def card
        trip.trip_payment&.card || trip.user.cards.last
      end

      def charge_driver_card
        return if Rails.env.development? #todo
        ::Fondy::ChargeCard.new(payment.order_reference, amount, driver_card_number).call
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
        @fondy_response ||= ::Fondy::Capture.new(payment.order_reference, amount).call
      end

      def success_response?
        @success_response ||= JSON.parse(fondy_response)['response']['response_status'] == 'success'
      end

      def update_total
        trip.update(total: trip.payments.sum(:amount))
      end

      def trip
        @trip ||= Trip.find(trip_id)
      end

      def payment
        @payment ||= Payment.find_by(payment_attributes)
      end

      def driver_card_number
        '4444555566661111' #todo
      end
    end
  end
end
