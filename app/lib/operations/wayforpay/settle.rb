module Operations
  module Wayforpay
    class Settle
      def initialize(trip_id)
        @trip_id = trip_id
      end

      attr_reader :trip_id

      def call
        return if payment.nil? || payment.status == Constants::Payments::BONUS
        if settle_response['reasonCode'] == Constants::Payments::WAYFORPAY_SUCCESS
          update_payment_status
          update_bonus_trip_if_necessary
          update_trip_total
        end
      end

      private

      def settle_response
        @settle_response ||= Operations::Wayforpay::SendPayment.new(card, trip.cost, 'Trip', payment.order_reference).call
      end

      def update_payment_status
        payment.update(status: Constants::Payments::SUCCESS)
      end

      def update_bonus_trip_if_necessary
        if frozen_bonuses.any? && count_of_finished_trips.positive?
          frozen_bonuses.first.update(status: Constants::BonusTrip::NEW)
        end
      end

      def update_trip_total
        trip.update(total: payment.amount)
      end

      def payment
        @payment ||= Payments::Trip.find_by(trip_id: trip_id)
      end

      def trip
        @trip ||= Trip.find(trip_id)
      end

      def frozen_bonuses
        @frozen_bonuses ||= BonusTrip.where(friend_id: trip.user_id, status: Constants::BonusTrip::FROZEN)
      end

      def card
        @card = Card.find(payment.card_id)
      end

      def count_of_finished_trips
        Trip.where(user_id: trip.user_id, status: Constants::Trip::FINISHED).count
      end
    end
  end
end