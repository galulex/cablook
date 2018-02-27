module Events
  module Trips
    class Cancel < Events::BaseEvent
      def schema
        Dry::Validation.Schema do
          configure { config.messages = :i18n }

          required(:trip_id).filled(:int?)
        end
      end

      def run
        if trip.status.in?([Constants::Trip::PENDING, Constants::Trip::ON_THE_WAY, Constants::Trip::WAITING_CLIENT])
          update_trip
          delete_from_jobs
          refund_payment
          broadcast_trip_unavailable
        else
          invalid!([I18n.t('trips.cancel_impossible')])
        end
      end

      private

      def update_trip
        Repositories::Trip.new(ROM.env).update(
          data[:trip_id],
          status: Constants::Trip::CANCELED
        )
      end

      def delete_from_jobs
        trip_job = Repositories::TripJob.new(ROM.env).by_trip_id(data[:trip_id])
        Jobs::SearchCarForTrip.cancel(trip_job.activejob_id) if trip_job
      end

      def broadcast_trip_unavailable
        ActionCable.server.broadcast(
          Constants::Channels::DRIVER_MAP,
          action: Constants::BroadcastActions::TRIP_UNAVAILABLE,
          errors: [I18n.t('trips.assigned_or_canceled')],
          driver_id: data[:driver_id],
          trip_id: data[:trip_id]
        )
      end

      def refund_payment
        if trip.status == Constants::Trip::WAITING_CLIENT
          Jobs::PaymentRefund.set(wait: 1.minute).perform_later(data[:trip_id], true)
        else
          Jobs::PaymentRefund.set(wait: 1.minute).perform_later(data[:trip_id])
        end
      end

      def trip
        @trip ||= Repositories::Trip.new(ROM.env).by_id(data[:trip_id])
      end
    end
  end
end
