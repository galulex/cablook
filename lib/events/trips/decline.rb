module Events
  module Trips
    class Decline < Events::BaseEvent
      def schema
        Dry::Schema.Params do
          required(:trip_id).filled(:int?)
        end
      end

      def run
        return if !trip.pending? || trip.driver.present?

        trip.declined!
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

      def update_payment
        trip_payment.update(status: Constants::Payments::DECLINE, response: declined_response)
      end

      def declined_response
        trip_payment.response.present? ? trip_payment.response.merge({ canceled_by: :timeout }) : { canceled_by: :timeout }
      end

      def notify
        return if trip.user.notification_settings.include?(Constants::User::DECLINE_TRIP)

        message = I18n.t('notification.car_not_found')
        Jobs::Notification.perform_later(trip, message)
        Jobs::DriversNotification.perform_later(trip, 'clear')
      end

      def telegram_message
        TelegramOrder.new(trip.telegram).update_step(:no_car_found) if trip.telegram && telegram_trip?(trip.user)
      end

      def order_reference
        @order_reference ||= trip.payments.find_by!(type: Constants::Payments::TRIP).order_reference
      end

      def trip_payment
        @trip_payment ||= trip.trip_payment
      end
    end
  end
end
