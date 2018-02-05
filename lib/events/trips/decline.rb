module Events
  module Trips
    class Decline < Events::BaseEvent
      def schema
        Dry::Validation.Schema do
          configure { config.messages = :i18n }

          required(:trip_id).filled(:int?)
        end
      end

      def run
        return unless trip.status == Constants::Trip::PENDING
        Repositories::Trip.new(ROM.env).update(trip.id, status: Constants::Trip::DECLINED)
        refund_payment
        broadcast && broadcast_to_trip_channel
      end

      private

      def refund_payment
        Jobs::PaymentRefund.perform_later(trip.id)
      end

      def trip
        @trip ||= Repositories::Trip.new(ROM.env).by_id(data[:trip_id])
      end

      def broadcast
        ActionCable.server.broadcast(
          Constants::Channels::DRIVER_MAP,
          action: Constants::BroadcastActions::TRIP_DECLINED,
          trip_id: trip.id
        )
      end

      def broadcast_to_trip_channel
        ActionCable.server.broadcast(
          "#{Constants::Channels::TRIP}_#{data[:trip_id]}",
          action: Constants::BroadcastActions::TRIP_DECLINED
        )
      end
    end
  end
end
