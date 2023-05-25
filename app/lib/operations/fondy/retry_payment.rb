module Operations
  module Fondy
    class RetryPayment < Base
      RETRY_SUFIX = '_retry'.freeze

      def initialize(payment_id, card_id)
        @payment_id = payment_id
        @card_id = card_id
      end

      attr_reader :payment_id, :card_id

      def call
        return unless card_id && card && card.fondy?

        if payment_status_success?
          update_payment(payment_status)
          return payment_status
        elsif retry_response_success?
          update_payment(retry_response)
          driver_pay_out
          add_cashback
        else
          payment.update(response: retry_response)
        end
        retry_response
      end

      private

      def payment_status_success?
        payment_status[:status]
      end

      def retry_response_success?
        retry_response[:status]
      end

      def update_payment(response)
        payment.update(
          status: Constants::Payments::SUCCESS,
          response: response,
          card_id: card_id,
          order_reference: response[:order_id]
        )
      end

      def driver_pay_out
        return if payment.type == Constants::Payments::PAYOUT

        Operations::Fondy::DriverPayOut.new(payment_id).call
      end

      def retry_response
        return retry_payout_response if payment.type == Constants::Payments::PAYOUT

        @retry_response ||= ::Fondy::Recurring.new(user, payment.amount, card.token, order_reference + RETRY_SUFIX).call
      end

      def retry_payout_response
        @retry_payout_response ||= ::Fondy::ChargeCard.new(payment).call
      end

      def payment_status
        @payment_status ||= ::Fondy::PaymentStatus.new(payment.order_reference).call
      end

      def order_reference
        @order_reference ||= OrderReference.new(payment.trip.id, payment.type).call
      end

      def add_cashback
        return unless settings.cashback && payment.type == Constants::Payments::TRIP

        user.update(cashback: user.cashback + cashback_amount)
      end

      def cashback_amount
        payment.amount * 0.05 * 100
      end

      def card
        @card ||= Card.find(card_id)
      end

      def payment
        @payment ||= Payment.find(payment_id)
      end

      def user
        @user ||= payment.user
      end
    end
  end
end
