module Operations
  module Wayforpay
    class DoPayment
      def initialize(trip_id, payment_type, amount)
        @trip_id = trip_id
        @payment_type = payment_type
        @amount = amount
      end

      attr_reader :trip_id, :payment_type, :amount

      def call
        return if payment.status == Constants::Payments::SUCCESS
        types = Constants::Payments::TYPES.except(:order).values
        case payment_type
        when types[1], types[2], types[3]
          update_payment_and_total
        when types[0]
          return if payment.status == Constants::Payments::BONUS
          update_payment_and_total
          return unless success_response?
          update_bonus_trip_if_necessary
          add_cashback
        end
        wayforpay_response['transactionStatus']
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

      def update_payment
        status = success_response? ? Constants::Payments::SUCCESS : Constants::Payments::PENDING
        payment.update(
          response: wayforpay_response,
          status: status,
          amount: amount || payment.amount,
          order_reference: order_reference
        )
      end

      def wayforpay_response
        @wayforpay_response ||= Operations::Wayforpay::SendPayment.new(card, amount || trip.cost, "Payments::#{payment_type}", order_reference).call
      end

      def success_response?
        @success_response ||= wayforpay_response ? wayforpay_response.dig('reasonCode') == Constants::Payments::WAYFORPAY_SUCCESS : false
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
        trip.trip_payment&.card || trip.user.cards.where(payment_system: :wayforpay).last
      end

      def update_payment_and_total
        update_payment
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

      def order_reference
        @order_reference ||= OrderReference.new(trip.id, payment_type.underscore).call
      end

      def settings
        @settings ||= Settings.get
      end
    end
  end
end
