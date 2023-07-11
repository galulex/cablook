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
        validate_hold_amount! if settings.fondy?
        update_trip_status
        update_payment
        update_bonus_trip if bonus?
        retry_trip_job(trip.id)
        notify
      end

      private

      def retry_trip_job(trip_id)
        Jobs::SearchCarForTrip.perform_now(trip_id) # broadcast
        Jobs::DeclineTrip.set(wait: Constants::Trip::EXPIRES_IN).perform_later(trip_id)
        Jobs::RefundHoldedAmount.set(wait: Constants::Trip::REFUND_HOLD_IN).perform_later(trip.id, trip.cost, order_reference) if settings.fondy?
      end

      def hold_success?
        payment_status[:order_status] == Constants::Payments::FONDY_APPROVED || hold_amount[:status]
      end

      def payment_status
        @payment_status ||= Fondy::PaymentStatus.new(order_reference).call
      end

      def hold_amount
        hold_amount_response = Fondy::Recurring.new(user, trip.cost, card_token, fresh_order_reference, true).call
        trip.trip_payment.update(order_reference: fresh_order_reference, response: hold_amount_response)

        hold_amount_response
      end

      def validate_hold_amount!
        invalid!([I18n.t('trips.cant_hold_amount')], status: 402) unless hold_success?
      end

      def card_token
        trip.trip_payment.card.token
      end

      def update_trip_status
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
        trip.bonus_trip.present? && settings.bonuses
      end

      def notify
        return if trip.user.notification_settings.include?(Constants::User::SEARCH_CAR)

        message = I18n.t('notification.loading')
        Jobs::Notification.perform_later(trip, message)
        Jobs::DriversNotification.perform_later(@trip)
      end

      def user
        @user ||= User.find(data[:user_id])
      end

      def trip
        @trip ||= Trip.find(data[:trip_id])
      end

      def cards
        @cards ||= Card.where(user_id: data[:user_id], payment_system: settings.payment_system)
      end

      def validate_user_cards!
        invalid!([I18n.t('trips.cant_retry')]) unless cards.any?
      end

      def order_reference
        trip.payments.find_by!(type: Constants::Payments::TRIP).order_reference
      end

      def fresh_order_reference
        @fresh_order_reference ||= OrderReference.new(trip.id).call
      end
    end
  end
end
