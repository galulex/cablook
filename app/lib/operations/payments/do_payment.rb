module Operations
  module Payments
    class DoPayment < Base
      def initialize(trip_id, payment_type, amount)
        @trip_id = trip_id
        @payment_type = payment_type
        @amount = amount
      end

      def call
        payment_class.new(trip_id, payment_type, amount).call
      end

      private

      attr_reader :trip_id, :payment_type, :amount

      def payment_class
        "Operations::#{payment_system}::DoPayment".classify.constantize
      end
    end
  end
end
