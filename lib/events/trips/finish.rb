module Events
  module Trips
    class Finish < Events::BaseEvent
      def schema
        Dry::Validation.Schema do
          configure { config.messages = :i18n }

          required(:trip_id).filled(:int?)
          optional(:idle).filled(:int?)
        end
      end

      # TODO: Impement logic when the price changed
      def run
        update_trip
        Jobs::PaymentSettle.perform_later(data[:trip_id])
        broadcast
        update_car
        settle_payment_idle if data[:idle]
      end

      private

      def update_trip
        trip.update(status: Constants::Trip::FINISHED, finished_at: Time.now)
      end

      def update_car
        return if next_trip?
        Car.find(trip.car_id).update(status: Constants::Car::FREE)
      end

      def broadcast
        ActionCable.server.broadcast(
          trip_channel,
          action: Constants::BroadcastActions::TRIP_FINISH_ACTION,
          body: { action: Constants::BroadcastActions::TRIP_FINISHED }
        )
      end

      def settle_payment_idle
        return if data[:idle] / 60 < 10
        Jobs::PaymentIdleSettle.perform_later(data[:trip_id], data[:idle])
      end

      def next_trip?
        Trip.where(
          driver_id: trip.driver_id,
          status: [Constants::Trip::ON_THE_WAY, Constants::Trip::WAITING_CLIENT, Constants::Trip::DRIVING]
        ).any?
      end

      def trip
        @trip ||= Trip.find(data[:trip_id])
      end

      def trip_channel
        "#{Constants::Channels::TRIP}_#{data[:trip_id]}"
      end
    end
  end
end
