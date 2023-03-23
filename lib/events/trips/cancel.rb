module Events
  module Trips
    class Cancel < Events::BaseEvent
      TRIP_STATUSES = [Constants::Trip::PENDING, Constants::Trip::ON_THE_WAY, Constants::Trip::WAITING_CLIENT, Constants::Trip::DECLINED, Constants::Trip::WAITING_FOR_VENDOR_APPROVE].freeze
      FAKE_TAXI_COST = 10.freeze

      def schema
        Dry::Validation.Schema do
          configure { config.messages = :i18n }

          required(:trip_id).filled(:int?)
          optional(:by_driver).filled(:bool?)
          optional(:notification)
        end
      end

      def run
        if data[:notification]
          broadcast_notification_cancel
        elsif trip && Trip.statuses[trip.status].in?(TRIP_STATUSES) || (trip && Trip.statuses[trip.status] == Constants::Trip::DRIVING) && data[:by_driver]
          run_methods
        else
          invalid!([I18n.t('trips.cancel_impossible')])
        end
      end

      private

      def run_methods
        update_car if trip.car
        update_trip
        update_payment_status
        fake_taxi_payment
        trip_refound_hold_payment
        refund_bonus
        broadcast_unavailable_to_map
        broadcast_unavailable_to_trip
        clear_notifications
      end

      def update_car
        return if next_trip?
        trip.car.update(status: Constants::Car::FREE)
      end

      def next_trip?
        Trip.where(
          driver_id: trip.driver_id,
          status: [Constants::Trip::ON_THE_WAY, Constants::Trip::WAITING_CLIENT, Constants::Trip::DRIVING]
        ).where.not(id: trip.id).any?
      end

      def update_trip
        return if trip.status == Constants::Trip::STATUS_CODES[Constants::Trip::DECLINED]
        status = data[:by_driver] ? Constants::Trip::CANCELED_BY_DRIVER : Constants::Trip::CANCELED
        trip.update(status: status)
      end

      def update_payment_status
        return unless payment.response.blank?
        payment.update(status: Constants::Payments::DECLINE, response: cencel_by_user_response)
      end

      def cencel_by_user_response
        { canceled_by: :user }.merge(trip_refound_hold_payment || {})
      end

      def trip_refound_hold_payment
        return if data[:by_driver]
        @trip_refound_hold_payment ||= Fondy::Reverse.new(trip.cost, payment.order_reference).call
      end

      def fake_taxi_payment
        return unless data[:by_driver]
        payment.update!(type: "Payments::#{Constants::Payments::TYPES[:fake]}")
        Jobs::PaymentSettle.perform_later(data[:trip_id], Constants::Payments::TYPES[:fake], FAKE_TAXI_COST)
      end

      def broadcast_notification_cancel
        ActionCable.server.broadcast(
          "#{Constants::Channels::TRIP}_#{trip.id}",
          action: Constants::BroadcastActions::NOTIFICATION_CANCEL,
          data: {
            delivered: true
          }
        )
      end

      def broadcast_unavailable_to_map
        ActionCable.server.broadcast(
          Constants::Channels::DRIVER_MAP,
          action: Constants::BroadcastActions::TRIP_UNAVAILABLE,
          errors: [I18n.t('trips.assigned_or_canceled')],
          driver_id: data[:driver_id],
          trip_id: data[:trip_id],
          by_driver: data[:by_driver]
        )
      end

      def broadcast_unavailable_to_trip
        ActionCable.server.broadcast(
          "#{Constants::Channels::TRIP}_#{trip.id}",
          action: Constants::BroadcastActions::TRIP_UNAVAILABLE,
          trip_id: data[:trip_id],
          by_driver: data[:by_driver]
        )
      end

      def clear_notifications
        message = 'clear'
        Jobs::Notification.perform_later(trip, message)
      end

      def trip
        @trip ||= Trip.find(data[:trip_id])
      end

      def payment
        @payment ||= trip.trip_payment
      end

      def order_payment
        @order_payment ||= trip.order.payment
      end

      def price
        @price ||= Price.last
      end

      def refund_bonus
        bonus_trip = BonusTrip.find_by(trip_id: trip.id)
        bonus_trip&.fresh!
      end
    end
  end
end
