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
        return unless trip.status == Constants::Trip::STATUS_CODES[Constants::Trip::PENDING]
        trip.update(status: Constants::Trip::DECLINED)
        trip.trip_payment.update(status: Constants::Payments::DECLINE)
        refund_bonus
        broadcast
        broadcast_to_trip_channel
        notify
        telegram_message
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
        bonus_trip&.update(status:  Constants::BonusTrip::STATUSES[Constants::BonusTrip::FRESH])
      end

      def notify
        return if trip.user.notification_settings.include?(Constants::User::DECLINE_TRIP)
        message = I18n.t('notification.car_not_found')
        Jobs::Notification.perform_later(trip.user_id, message)
      end

      def telegram_message
        TelegramOrder.new(trip.telegram).update_step(:no_car_found) if trip.telegram && telegram_trip?(trip.user)
      end
    end
  end
end
