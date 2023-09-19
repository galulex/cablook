module Events
  module Trips
    class Start < Events::BaseEvent
      def schema
        Dry::Schema.Params do
          # configure { config.messages = :i18n }

          required(:trip_id).filled(:int?)
        end
      end

      def run
        update_trip
        broadcast
        notify if delivery_trip?
      end

      private

      def trip
        @trip ||= Trip.find(data[:trip_id])
      end

      def update_trip
        trip.update(status: Constants::Trip::DRIVING, started_at: Time.now)
      end

      def notify
        return if trip.user.notification_settings.include?(Constants::User::WAITING_CLIENT)

        message = I18n.t('notification.waiting')
        Jobs::Notification.perform_later(trip, message)
      end

      def delivery_trip?
        @trip.order.present?
      end

      def broadcast
        ActionCable.server.broadcast(
          trip_channel,
          {
            action: Constants::BroadcastActions::TRIP_START_ACTION,
            body: { action: Constants::BroadcastActions::TRIP_STARTED }
          }
        )
      end

      def trip_channel
        "#{Constants::Channels::TRIP}_#{data[:trip_id]}"
      end
    end
  end
end
