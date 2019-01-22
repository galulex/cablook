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

      def cards
        @cards ||= Card.where(user_id: data[:user_id])
      end
    end
  end
end
