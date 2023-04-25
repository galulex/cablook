module Operations
  module Payments
    class RetryPayment < Base
      def initialize(payment_id, card_id)
        @payment_id = payment_id
        @card_id = card_id
      end

      def call
        payment_class.new(payment_id, card_id).call
      end

      private

      attr_reader :payment_id, :card_id

      def payment_class
        "Operations::#{payment_system}::RetryPayment".classify.constantize
      end
    end
  end
end
