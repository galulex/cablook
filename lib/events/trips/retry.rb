module Events
  module Trips
    class Retry < Events::BaseEvent
      def schema
        Dry::Validation.Schema do
          configure { config.messages = :i18n }

          required(:trip_id).filled(:int?)
          required(:user_id).filled(:int?)
        end
      end

      def run
        validate_user_cards!
        update_trip
        update_payment
        update_bonus_trip if bonus?
        retry_trip_job(trip.id)
        trip
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
        trip.bonus_trip.update(status: Constants::BonusTrip::STATUSES[Constants::BonusTrip::USED])
      end

      def bonus?
        trip.bonus_trip.present?
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
