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
        return if !trip.pending? || trip.driver.present?

        trip.declined!
        refund_holded_amount if settings.fondy?
        update_payment
        refund_bonus if settings.bonuses
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
        bonus_trip&.fresh!
      end

      def refund_holded_amount
        return {} unless settings.fondy?
        @refund_holded_amount ||= Fondy::Reverse.new(trip.cost, trip.trip_payment.order_reference).call
      end

      def update_payment
        trip.trip_payment.update(status: Constants::Payments::DECLINE, response: {canceled_by: :timeout}.merge(refund_holded_amount) )
      end

      def notify
        return if trip.user.notification_settings.include?(Constants::User::DECLINE_TRIP)
        message = I18n.t('notification.car_not_found')
        Jobs::Notification.perform_later(trip, message)
      end

      def telegram_message
        TelegramOrder.new(trip.telegram).update_step(:no_car_found) if trip.telegram && telegram_trip?(trip.user)
      end
    end
  end
end
