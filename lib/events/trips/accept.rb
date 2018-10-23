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
        if trip.status == Constants::Trip::STATUS_CODES[Constants::Trip::PENDING]
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
        start_at = matrix.duration.seconds.since + 2.minutes
        trip.with_lock do
          trip.update(
            status: Constants::Trip::ON_THE_WAY,
            car_id: data[:car_id],
            driver_id: data[:driver_id],
            start_at: car_trip ? (start_at + car_trip_remaining_time) : start_at
          )
        end
      end

      def update_car_status
        car.update(status: Constants::Car::DURING_TRIP)
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
          driver: driver.attributes.merge('car' => car.attributes),
          trip: Presenters::Trips::Detailed.new(trip)
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
        @matrix ||= Directions.new(start_point, trip.departure, [])
      end

      def start_point
        car_trip ? car_trip.destination.join(',') : Redis.current.get("car_#{data[:car_id]}")&.split(',')
      end

      def car_trip
        @car_trip ||= Trip.find_by(car_id: data[:car_id], status: [Constants::Trip::DRIVING, Constants::Trip::ON_THE_WAY, Constants::Trip::WAITING_CLIENT])
      end

      def car_trip_remaining_time
        expected_finish_time = ((car_trip.started_at || car_trip.start_at) + car_trip.duration)
        Time.now > expected_finish_time ? 0.minutes : ((expected_finish_time - Time.now) / 60).round.minutes
      end

      def car
        @car ||= Car.find(data[:car_id])
      end

      def trip
        @trip ||= Trip.find(data[:trip_id])
      end

      def driver
        @driver ||= Driver.find(data[:driver_id])
      end
    end
  end
end
