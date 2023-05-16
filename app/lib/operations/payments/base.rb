module Operations
  module Payments
    class Base
      private

      def payment_system
        determine_payment_method.to_s.camelcase
      end

      def determine_payment_method
        is_fondy_method? ? :fondy : :wayforpay
      end

      def is_fondy_method?
        card&.fondy? && settings.fondy? && card&.user.fondy?
      end

      def card
        return card_for_retry if self.kind_of?(Operations::Payments::RetryPayment)

        Trip.find(trip_id).payments.where(type: "Payments::#{payment_type}").first.card
      end

      def card_for_retry
        Card.find_by(id: card_id) || Payment.find(payment_id).user.cards.first
      end

      def settings
        Settings.get
      end
    end
  end
end
