module Operations
  module Fondy
    class RetryPayment < Base
      def initialize(payment_id, card_id)
        @payment_id = payment_id
        @card_id = card_id
      end

      attr_reader :payment_id, :card_id

      def call
        return unless card_id && card && card.payment_system == settings.payment_system['fondy']
        if JSON.parse(payment_status)['response']['order_status'] == Constants::Payments::FONDY_APPROVED
          payment.update(status: Constants::Payments::SUCCESS, response: payment_status)
          return payment_status
        elsif JSON.parse(retry_response)['response']['response_status'] == Constants::Payments::FONDY_SUCCESS
          payment.update(status: Constants::Payments::SUCCESS, response: retry_response)
          add_cashback if payment.type == 'Payments::Trip'
        else
          payment.update(response: retry_response)
        end
        retry_response
      end

      private

      def retry_response
        @retry_response ||= ::Fondy::Recurring.new(user, payment.amount, card.token, order_reference).call
      end

      def payment_status
        @payment_status ||= ::Fondy::PaymentStatus.new(payment.order_reference).call
      end

      def order_reference
        secure_code = SecureRandom.base58(6)
        @order_reference ||= if Rails.env.production?
                               "cablook_#{payment.trip.id}_payments_#{payment.type}_#{secure_code}"
                             else
                               "cablook_#{Rails.env}_#{payment.trip.id}_payments_#{payment.type}_#{secure_code}"
                             end
      end

      def add_cashback
        return unless settings.cashback
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
