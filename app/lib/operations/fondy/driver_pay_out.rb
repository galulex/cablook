module Operations
  module Fondy
    class DriverPayOut < Base
      def initialize(payment_id)
        @payment_id = payment_id
      end

      attr_reader :payment_id

      def call
        payout_driver
      end

      private

      def payout_driver
        Payment.create(
          trip_id: payment.trip.id,
          user_id: payment.user.id,
          card_id: payment.card.id,
          type: Constants::Payments::PAYOUT,
          response: payout_response,
          status: pay_out_status ? Constants::Payments::SUCCESS : Constants::Payments::PENDING,
          amount: payment.amount)
      end

      def pay_out_status
        payout_response[:response_status] == Constants::Payments::FONDY_SUCCESS
      end

      def payout_response
        return { response_status: 'success', payout: 'Driver payout'} unless Rails.env.production?
        ::Fondy::ChargeCard.new(payment.order_reference, payment.amount, driver_card_number).call
      end

      def driver_card_number
        payment.driver.card_number
      end

      def payment
        @payment ||= Payment.find(payment_id)
      end
    end
  end
end
