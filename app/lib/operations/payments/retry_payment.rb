module Operations
  module Payments
    class RetryPayment < Base
      def initialize(payment_id, card_id)
        @payment_id = payment_id
        @card_id = card_id
      end

      def call
        payment_class.new(payment_id, card&.id).call
      end

      private

      attr_reader :payment_id, :card_id

      def payment_class
        "Operations::#{payment_system}::RetryPayment".classify.constantize
      end

      def card
        card_for_retry = Card.find_by(id: card_id)
        return card_for_retry if card_for_retry&.payment_system == settings.payment_system

        payment.user.cards.where(payment_system: settings.payment_system).first
      end

      def payment
        Payment.find(payment_id)
      end
    end
  end
end
