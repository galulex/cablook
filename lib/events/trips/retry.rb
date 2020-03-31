module Events
  module Trips
    class Retry < Events::BaseEvent
      def schema
        Dry::Validation.Schema do
          configure { config.messages = :i18n }

          required(:trip_id).filled(:int?)
          required(:user_id).filled(:int?)
          optional(:notification)
        end
      end

      def run
        if data[:notification]
          broadcast if trip.status == Constants::Trip::STATUS_CODES[Constants::Trip::DECLINED]
        else
          run_methods
        end
        trip
      end

      def run_methods
        validate_user_cards!
        update_trip
        update_payment
        update_bonus_trip if bonus?
        retry_trip_job(trip.id)
        notify
      end

      private

      def retry_trip_job(trip_id)
        Jobs::SearchCarForTrip.perform_now(trip_id) #broadcast
        Jobs::DeclineTrip.set(wait: Constants::Trip::EXPIRES_IN).perform_later(trip_id)
      end

      def update_trip
        trip.update(status: Constants::Trip::PENDING)
      end

      def update_payment
        trip.trip_payment.update(status: bonus? ? Constants::Payments::BONUS : Constants::Payments::PENDING)
      end

      def update_bonus_trip
        trip.bonus_trip.used!
      end

      def broadcast
        ActionCable.server.broadcast(
          "#{Constants::Channels::TRIP}_#{trip.id}",
          action: Constants::BroadcastActions::NOTIFICATION_RETRY,
          data: {
            delivered: true
          }
        )
      end

      def bonus?
        trip.bonus_trip.present?
      end

      def notify
        message = I18n.t('notification.loading')
        Jobs::Notification.perform_later(trip.user_id, message, trip)
      end

      def trip
        @trip ||= Trip.find(data[:trip_id])
      end

      def cards
        @cards ||= Card.where(user_id: data[:user_id])
      end

      def validate_user_cards!
        invalid!([I18n.t('trips.cant_retry')]) unless cards.any?
      end
    end
  end
end
