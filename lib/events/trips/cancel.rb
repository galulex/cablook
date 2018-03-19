module Events
  module Trips
    class Cancel < Events::BaseEvent
      def schema
        Dry::Validation.Schema do
          configure { config.messages = :i18n }

          required(:trip_id).filled(:int?)
          optional(:by_driver).filled(:bool?)
        end
      end

      def run
        if trip.status.in?([Constants::Trip::PENDING, Constants::Trip::ON_THE_WAY, Constants::Trip::WAITING_CLIENT])
          update_trip
          delete_from_jobs
          refund_payment
          broadcast_unavailable_to_map
          broadcast_unavailable_to_trip
        else
          invalid!([I18n.t('trips.cancel_impossible')])
        end
      end

      private

      def update_trip
        status = data[:by_driver] ? Constants::Trip::CANCELED_BY_DRIVER : Constants::Trip::CANCELED
        Repositories::Trip.new(ROM.env).update(
          data[:trip_id],
          status: status
        )
      end

      def delete_from_jobs
        trip_job = Repositories::TripJob.new(ROM.env).by_trip_id(data[:trip_id])
        Jobs::SearchCarForTrip.cancel(trip_job.activejob_id) if trip_job
      end

      def refund_payment
        return if payment&.status == Constants::Payments::REFUND
        if trip.status == Constants::Trip::WAITING_CLIENT
          Jobs::PaymentRefund.perform_later(data[:trip_id], true)
        else
          Jobs::PaymentRefund.perform_later(data[:trip_id])
        end
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
        @trip ||= Repositories::Trip.new(ROM.env).by_id(data[:trip_id])
      end

      def payment
        @payment ||= Repositories::Payment.new(ROM.env).by_trip(trip.id)
      end
    end
  end
end
