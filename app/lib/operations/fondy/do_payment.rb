module Operations
  module Fondy
    class DoPayment < Base
      def initialize(trip_id, payment_type, amount)
        @trip_id = trip_id
        @payment_type = payment_type
        @amount = amount
      end

      attr_reader :trip_id, :payment_type, :amount

      def call
        return if payment.payment_method == Constants::Payments::METHOD_MOBILE || payment.status == Constants::Payments::SUCCESS

        types = Constants::Payments::TYPES.except(:order, :payout).values
        case payment_type
        when types[0]
          return if payment.status == Constants::Payments::BONUS

          update_payment_and_total(success_response?(capture_response), capture_response)
          return unless success_response?(capture_response)

          update_bonus_trip_if_necessary
          add_cashback
          update_driver_balance
        when types[1], types[2]
          update_payment_and_total(success_response?(recurring_response), recurring_response)
          update_driver_balance if success_response?(recurring_response)
        when types[3]
          update_payment_and_total(success_response?(capture_response), capture_response)
          update_driver_balance if success_response?(capture_response)
        end
        capture_response[:response_status]
      end

      private

      def payment_attributes
        {
          trip_id: trip_id,
          user_id: trip.user_id,
          card_id: card.id,
          type: "Payments::#{payment_type}"
        }
      end

      def update_driver_balance
        trip.driver.update!(balance: trip.driver.balance + payment.amount)
      end

      def update_payment(success, response)
        status = success ? Constants::Payments::SUCCESS : Constants::Payments::PENDING
        payment.update(
          response: response,
          status: status,
          amount: amount || payment.amount,
          order_reference: response[:order_id] || payment.order_reference
        )
      end

      def update_bonus_trip_if_necessary
        return unless settings.bonuses

        frozen_bonuses = trip.user.bonus_trips.iced
        frozen_bonuses.first.fresh! if frozen_bonuses.any? && trip.user.trips.finished.count.positive?
      end

      def update_total
        trip.update(total: trip.payments.sum(:amount))
      end

      def card
        @card ||= trip.payments.find_by(type: "Payments::#{payment_type}").card
      end

      def update_payment_and_total(success, response)
        update_payment(success, response)
        update_total
      end

      def add_cashback
        return unless settings.cashback

        user.update(cashback: user.cashback + cashback_amount)
      end

      def cashback_amount
        trip.cost * 0.05 * 100
      end

      def trip
        @trip ||= Trip.find(trip_id)
      end

      def user
        @user ||= trip.user
      end

      def payment
        @payment ||= Payment.find_or_create_by(payment_attributes)
      end

      def capture_response
        @capture_response ||= ::Fondy::Capture.new(payment.order_reference, amount || payment.amount).call
      end

      def recurring_response
        @recurring_response ||= ::Fondy::Recurring.new(user, amount || payment.amount, card.token, order_reference).call
      end

      def order_reference
        @order_reference ||= OrderReference.new(@trip.id, payment_type).call
      end

      def success_response?(response)
        response[:status]
      end
    end
  end
end
