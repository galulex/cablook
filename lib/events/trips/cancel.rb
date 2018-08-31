module Events
  module Trips
    class Cancel < Events::BaseEvent
      TRIP_STATUSES = [Constants::Trip::PENDING, Constants::Trip::ON_THE_WAY, Constants::Trip::WAITING_CLIENT, Constants::Trip::DECLINED].freeze

      def schema
        Dry::Validation.Schema do
          configure { config.messages = :i18n }

          required(:trip_id).filled(:int?)
          optional(:by_driver).filled(:bool?)
        end
      end

      def run
        if trip && Trip.statuses[trip.status].in?(TRIP_STATUSES) || (trip && Trip.statuses[trip.status] == Constants::Trip::DRIVING) && data[:by_driver]
          run_methods
        else
          invalid!([I18n.t('trips.cancel_impossible')])
        end
      end

      private

      def run_methods
        delete_from_jobs
        update_car if trip.car
        update_payment_status
        fake_taxi_payment
        update_trip
        refund_bonus
        broadcast_unavailable_to_map
        broadcast_unavailable_to_trip
      end

      def update_car
        trip.car.update(status: Constants::Car::FREE) unless next_trip?
      end

      def next_trip?
        Trip.where(
          driver_id: trip.driver_id,
          status: [Constants::Trip::ON_THE_WAY, Constants::Trip::WAITING_CLIENT, Constants::Trip::DRIVING]
        ).any?
      end

      def update_trip
        return if trip.status == Constants::Trip::STATUS_CODES[Constants::Trip::DECLINED]
        status = data[:by_driver] ? Constants::Trip::CANCELED_BY_DRIVER : Constants::Trip::CANCELED
        trip.update(status: status)
      end

      def delete_from_jobs
        trip_job = TripJob.find_by(trip_id: data[:trip_id])
        Jobs::SearchCarForTrip.cancel(trip_job.activejob_id) if trip_job
      end

      def update_payment_status
        payment.update(status: Constants::Payments::DECLINE)
      end

      def fake_taxi_payment
        return unless trip.status == Constants::Trip::STATUS_CODES[Constants::Trip::WAITING_CLIENT]
        Jobs::PaymentFakeSettle.perform_later(data[:trip_id])
      end

      def broadcast_unavailable_to_map
        ActionCable.server.broadcast(
          Constants::Channels::DRIVER_MAP,
          action: Constants::BroadcastActions::TRIP_UNAVAILABLE,
          errors: [I18n.t('trips.assigned_or_canceled')],
          driver_id: data[:driver_id],
          trip_id: data[:trip_id],
          by_driver: data[:by_driver]
        )
      end

      def broadcast_unavailable_to_trip
        ActionCable.server.broadcast(
          "#{Constants::Channels::TRIP}_#{trip.id}",
          action: Constants::BroadcastActions::TRIP_UNAVAILABLE,
          trip_id: data[:trip_id],
          by_driver: data[:by_driver]
        )
      end

      def trip
        @trip ||= Trip.find(data[:trip_id])
      end

      def payment
        @payment ||= trip.trip_payment
      end

      def refund_bonus
        bonus_trip = BonusTrip.find_by(trip_id: trip.id)
        bonus_trip&.update(status: Constants::BonusTrip::NEW)
      end
    end
  end
end
