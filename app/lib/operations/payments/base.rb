module Operations
  module Payments
    class Base
      private

      def payment_system
        determine_payment_method.to_s.camelcase
      end

      def determine_payment_method
        settings.fondy? ? :fondy : :wayforpay
      end

      def card
        return card_for_retry if is_a?(Operations::Payments::RetryPayment)

        trip_payments_card
      end

      def card_for_retry
        card_for_retry = Card.find_by(id: card_id)
        return card_for_retry if card_for_retry.payment_system == settings.payment_system

        payment.user.cards.where(payment_system: settings.payment_system).first
      end

      def trip_payments_card
        trip_payments_card = trip.payments.where(type: "Payments::#{payment_type}").first.card
        return trip_payments_card if trip_payments_card.payment_system == settings.payment_system

        trip.user.cards.where(payment_system: settings.payment_system).first
      end

      def trip
        @trip ||= Trip.find(trip_id)
      end

      def payment
        Payment.find(payment_id)
      end

      def settings
        Settings.get
      end
    end
  end
end
