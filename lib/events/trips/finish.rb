module Events
  module Trips
    class Finish < Events::BaseEvent
      def schema
        Dry::Validation.Schema do
          configure { config.messages = :i18n }

          required(:trip_id).filled(:int?)
        end
      end

      # TODO: Impement logic when the price changed
      def run
        update_trip
        Jobs::PaymentSettle.perform_later(data[:trip_id])
        broadcast
        update_car
      end

      private

      def update_trip
        Repositories::Trip.new(ROM.env).update(
          data[:trip_id],
          status: Constants::Trip::FINISHED,
          finished_at: Time.now
        )
      end

      def update_car
        return if next_trip?
        Repositories::Car.new(ROM.env).update(trip.car_id, status: Constants::Car::FREE)
      end

      def broadcast
        ActionCable.server.broadcast(
          trip_channel,
          action: Constants::BroadcastActions::TRIP_FINISH_ACTION,
          body: { action: Constants::BroadcastActions::TRIP_FINISHED }
        )
      end

      def next_trip?
        Repositories::Trip.new(ROM.env).currents(trip.driver_id).any?
      end

      def trip
        @trip ||= Repositories::Trip.new(ROM.env).by_id(data[:trip_id])
      end

      def trip_channel
        "#{Constants::Channels::TRIP}_#{data[:trip_id]}"
      end
    end
  end
end
