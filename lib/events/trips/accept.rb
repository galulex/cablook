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
          update_car_status
          update_trip
          telegram_message
          broadcast_accepted_trip
          broadcast_accepted_trip_to_trip_channel
          notify
        else
          broadcast_with_error
        end
      end

      private

      def update_trip
        trip.with_lock do
          trip.update(
            status: trip_status,
            car_id: data[:car_id],
            driver_id: data[:driver_id],
            start_at: start_time
          )
        end
      end

      def update_car_status
        car.update(status: Constants::Car::DURING_TRIP) unless trip.preorder?
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

      def trip_status
        Constants::Trip::ON_THE_WAY
      end

      def start_time
        return trip.start_at if trip.preorder?
        @start_time ||= car_trip ? (start_at + car_trip_remaining_time) : start_at
      end

      def start_at
        @start_at ||= matrix.duration.seconds.since + 2.minutes
      end

      def start_point
        car_trip ? car_trip.destination : Redis.current.get("car_#{data[:car_id]}")&.split(',')
      end

      def car_trip
        @car_trip ||= Trip.where(car_id: data[:car_id], status: [Constants::Trip::DRIVING, Constants::Trip::ON_THE_WAY, Constants::Trip::WAITING_CLIENT], preorder_time: nil).last
      end

      def car_trip_remaining_time
        expected_finish_time = ((car_trip.started_at || car_trip.start_at) + car_trip.duration)
        Time.now > expected_finish_time ? 0.minutes : ((expected_finish_time - Time.now) / 60).round.minutes
      end

      def notify
        return if trip.user.notification_settings.include?(Constants::User::ACCEPT_TRIP)
        message = I18n.t('notification.will_arrive', name: driver.name, car: car.number, time: start_time.strftime('%H:%M'))
        Jobs::Notification.perform_later(trip.user_id, message)
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

      def telegram_message
        TelegramOrder.new(trip.telegram).driver_found(:accept, driver.username, car.phone_number) if trip.telegram && telegram_trip?(trip.user)
      end
    end
  end
end
