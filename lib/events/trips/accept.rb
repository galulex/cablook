module Events
  module Trips
    class Accept < Events::BaseEvent
      def schema
        Dry::Validation.Schema do
          configure { config.messages = :i18n }

          required(:trip_id).filled(:int?)
          required(:driver_id).filled(:int?)
          required(:car_id).filled(:int?)
        end
      end

      def run
        if trip.status == Constants::Trip::PENDING
          update_trip
          update_car_status
          broadcast_accepted_trip
          broadcast_accepted_trip_to_trip_channel
        else
          broadcast_with_error
        end
      end

      private

      def update_trip
        @trip = Repositories::Trip.new(ROM.env).update(
          data[:trip_id],
          status: Constants::Trip::ON_THE_WAY,
          car_id: data[:car_id],
          driver_id: data[:driver_id],
          start_at: matrix.duration.seconds.since
        )
      end

      def update_car_status
        Repositories::Car.new(ROM.env).update(
          data[:car_id],
          status: Constants::Car::DURING_IN_TRIP
        )
      end

      def broadcast_accepted_trip
        ActionCable.server.broadcast(
          Constants::Channels::DRIVER_MAP,
          action: Constants::BroadcastActions::TRIP_ACCEPTED,
          trip_id: trip.id,
          driver_id: trip.driver_id,
          car_id: trip.car_id
        )
      end

      def broadcast_accepted_trip_to_trip_channel
        ActionCable.server.broadcast(
          "#{Constants::Channels::TRIP}_#{data[:trip_id]}",
          action: Constants::BroadcastActions::TRIP_ACCEPTED,
          driver: driver,
          trip: trip
        )
      end

      def broadcast_with_error
        ActionCable.server.broadcast(
          Constants::Channels::DRIVER_MAP,
          action: Constants::BroadcastActions::TRIP_UNAVAILABLE,
          errors: [I18n.t('trips.assigned_or_canceled')],
          driver_id: data[:driver_id],
          trip_id: data[:trip_id]
        )
      end

      def matrix
        @matrix ||= SearchEngine::Matrix.new(Redis.current.get("car_#{data[:car_id]}")&.split(','), car_trip&.destination, trip.departure)
      end

      def car_trip
        @car_trip ||= Repositories::Trip.new(ROM.env).trips.where(car_id: trip.car_id, status: Constants::Trip::DRIVING).one
      end

      def trip
        @trip ||= Repositories::Trip.new(ROM.env).by_id(data[:trip_id])
      end

      def driver
        @driver ||= Repositories::Driver.new(ROM.env).by_id_with_car(data[:driver_id])
      end
    end
  end
end
