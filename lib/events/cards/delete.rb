module Events
  module Cards
    class Delete < BaseEvent
      def schema
        Dry::Validation.Schema do
          configure { config.messages = :i18n }

          required(:card_id).filled(:int?)
          required(:user_id).filled(:int?)
        end
      end

      def run
        validate_pending_payments!
        validate_current_trip!
        delete_card if cards.any? { |card| card.id == data[:card_id] }
      end

      private

      def delete_card
        Card.destroy(data[:card_id])
      end

      def validate_pending_payments!
        pending_payment_trips = Trip.unpaid.where(user_id: data[:user_id])
        invalid!([I18n.t('cards.cant_delete')]) if pending_payment_trips.any?
      end

      def validate_current_trip!
        current_trip = Trip.includes(:order).where(user_id: data[:user_id]).where(orders: { trip_id: nil }).find_by(status: Constants::Trip::CURRENT_TRIP_STATUSES)
        invalid!([I18n.t('cards.current_trip')]) if current_trip
      end

      def cards
        @cards ||= Card.where(user_id: data[:user_id])
      end
    end
  end
end
