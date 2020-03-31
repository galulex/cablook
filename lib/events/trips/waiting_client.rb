module Events
  module Trips
    class WaitingClient < Events::BaseEvent
      def schema
        Dry::Validation.Schema do
          configure { config.messages = :i18n }

          required(:trip_id).filled(:int?)
        end
      end

      def run
        update_trip
        telegram_message
        broadcast
        notify unless trip.order
      end

      private

      def update_trip
        trip.update(params)
      end

      def params
        if trip.preorder?
          { status: Constants::Trip::WAITING_CLIENT, arrived_at: Time.now, start_at: trip.preorder_time, preorder_time: nil }
        else
          { status: Constants::Trip::WAITING_CLIENT, arrived_at: Time.now }
        end
      end

      def broadcast
        ActionCable.server.broadcast(
          trip_channel,
          action: Constants::BroadcastActions::TRIP_WAITING_ACTION,
          body: { action: Constants::BroadcastActions::TRIP_WAITING }
        )
      end

      def notify
        return if trip.user.notification_settings.include?(Constants::User::WAITING_CLIENT)
        message = I18n.t('notification.waiting')
        Jobs::Notification.perform_later(trip.user_id, message, trip)
      end

      def trip_channel
        "#{Constants::Channels::TRIP}_#{data[:trip_id]}"
      end

      def trip
        @trip = Trip.find(data[:trip_id])
      end

      def telegram_message
        TelegramOrder.new(trip.telegram).update_step(:waiting_client) if trip.telegram && telegram_trip?(trip.user)
      end
    end
  end
end
