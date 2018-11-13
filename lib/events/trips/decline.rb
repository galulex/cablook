module Events
  module Trips
    class Decline < Events::BaseEvent
      TRIP_STATUSES = [Constants::Trip::PENDING, Constants::Trip::PRE_ORDERED].freeze

      def schema
        Dry::Validation.Schema do
          configure { config.messages = :i18n }

          required(:trip_id).filled(:int?)
        end
      end

      def run
        return unless Trip.statuses[trip.status].in?(TRIP_STATUSES)
        trip.update(status: Constants::Trip::DECLINED)
        trip.trip_payment.update(status: Constants::Payments::DECLINE)
        refund_bonus
        broadcast
        broadcast_to_trip_channel
      end

      private

      def trip
        @trip ||= Trip.find(data[:trip_id])
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

      def refund_bonus
        bonus_trip = BonusTrip.find_by(trip_id: trip.id)
        bonus_trip&.update(status: Constants::BonusTrip::NEW)
      end
    end
  end
end
