module Operations
  module Fondy
    class RetryPayment
      def initialize(payment_id)
        @payment_id = payment_id
      end

      attr_reader :payment_id, :card_id

      def call
        return if payment.type == "Payments::#{Constants::Payments::TYPES[:payout]}"
        if JSON.parse(retry_response)['response']['response_status'] == Constants::Payments::FONDY_SUCCESS
          payment.update(status: Constants::Payments::SUCCESS, response: retry_response)
        else
          payment.update(response: retry_response)
        end
        retry_response
      end

      private

      def retry_response
        @retry_response ||= Operations::Fondy::DoPayment.new(payment.trip_id, payment.type, payment.amount).call
      end

      def payment
        @payment ||= Payment.find(payment_id)
      end
    end
  end
end
