module Operations
  module Wayforpay
    class DoPayment
      def initialize(trip_id, payment_type, amount=nil)
        @trip_id = trip_id
        @payment_type = payment_type
        @amount = amount
      end

      attr_reader :trip_id, :payment_type, :idle

      def call
        send("set_#{payment_type.underscore}_payment")
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

      def update_payment(status)
        payment.update(
          response: wayforpay_response,
          status: status,
          amount: @amount || payment.amount,
          order_reference: payment.order_reference || order_reference
        )
      end

      def wayforpay_response
        @wayforpay_response ||= Operations::Wayforpay::SendPayment.new(card, @amount || trip.cost, "Payments::#{payment_type}", payment.order_reference || order_reference).call
      end

      def success_response?
        @success_response ||= wayforpay_response['reasonCode'] == Constants::Payments::WAYFORPAY_SUCCESS
      end

      def update_bonus_trip_if_necessary
        frozen_bonuses.first.update(status: Constants::BonusTrip::STATUS[Constants::BonusTrip::FRESH]) if frozen_bonuses.any? && count_of_finished_trips.positive?
      end

      def update_total(idle)
        total = trip.payments.sum(:amount)
        idle ? trip.update(idle: @amount, total: total) : trip.update(total: total)
      end

      def card
        trip.trip_payment.card || trip.user.cards.last
      end

      def set_trip_payment
        return if payment.nil? || payment.status == Constants::Payments::BONUS
        update_payment_and_total
        update_bonus_trip_if_necessary if success_response?
      end

      def set_fake_taxi_payment
        update_payment_and_total
      end

      def set_idle_payment
        update_payment_and_total(true)
      end

      def set_tip_payment
        update_payment_and_total
      end

      def update_payment_and_total(idle = false)
        update_payment(success_response? ? Constants::Payments::SUCCESS : Constants::Payments::PENDING)
        update_total(idle) if success_response?
      end

      def trip
        @trip ||= Trip.find(trip_id)
      end

      def payment
        @payment ||= Payment.find_or_create_by(payment_attributes)
      end

      def price
        @price ||= Price.last
      end

      def user
        @user ||= User.find(trip.user_id)
      end

      def frozen_bonuses
        @frozen_bonuses ||= user.bonus_trips.iced
      end

      def count_of_finished_trips
        Trip.where(user_id: trip.user_id, status: Constants::Trip::FINISHED).count
      end

      def order_reference
        secure_code = SecureRandom.base58(6)
        @order_reference ||= if Rails.env.production?
                               "cablook_#{trip.id}_#{payment_type.underscore}_#{secure_code}"
                             else
                               "cablook_#{Rails.env}_#{trip.id}_#{payment_type.underscore}_#{secure_code}"
                             end
      end
    end
  end
end
