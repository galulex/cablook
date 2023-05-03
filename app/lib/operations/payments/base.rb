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
        card.fondy? && settings.fondy? && settings.is_allowed_for_fondy?(card.user.phone_number)
      end

      def card
        return Card.find(card_id) if self.kind_of?(Operations::Payments::RetryPayment)

        Trip.find(trip_id).payments.where(type: "Payments::#{payment_type}").first.card
      end

      def settings
        Settings.get
      end
    end
  end
end
