module Operations
  module Wayforpay
    class Settle
      def initialize(trip_id)
        @trip_id = trip_id
      end

      attr_reader :trip_id

      # TODO: Impement logic when the price changed
      # TODO: REFACTOR DB CONNECTIONS !!!!11111!!!
      def call
        wayforpay_response = JSON.parse(settle_payment.body)
        if wayforpay_response['reasonCode'] == Constants::Payments::WAYFORPAY_SUCCESS
          update_payment_status
          update_bonus_trip_if_necessary
        end
      end

      private

      def settle_payment
        ::Wayforpay::Payments.settle(
          orderReference: payment.order_reference,
          amount: payment.amount,
          currency: 'UAH'
        )
      end

      def update_payment_status
        payment_repository.update(payment.id, status: Constants::Payments::SUCCESS)
      end

      def update_bonus_trip_if_necessary
        count = trip_repository.count_of_finished_for_user(trip.user_id)
        if count == 1 && bonus_trips.any?
          bonus_trip_repository.update(bonus_trips.first.id, status: Constants::BonusTrip::NEW)
        end
      end

      def payment
        @payment ||= payment_repository.by_trip(trip_id)
      end

      def trip
        @trip ||= trip_repository.by_id(trip_id)
      end

      def bonus_trips
        @bonus_trips ||= bonus_trip_repository.by_friend(trip.user_id)
      end

      def bonus_trip_repository
        @bonus_trip_repository ||= Repositories::BonusTrip.new(ROM.env)
      end

      def payment_repository
        @payment_repository ||= Repositories::Payment.new(ROM.env)
      end

      def trip_repository
        @trip_repository ||= Repositories::Trip.new(ROM.env)
      end
    end
  end
end
