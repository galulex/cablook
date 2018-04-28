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
        payment_repository.nullify_card(data[:card_id])
        card_repository.delete(data[:card_id])
      end

      def validate_pending_payments!
        payments = payment_repository.hold_or_pending_by_user(data[:user_id])
        invalid!([I18n.t('cards.cant_delete')]) if payments.any?
      end

      def cards
        @cards ||= card_repository.by_user(data[:user_id])
      end

      def card_repository
        @card_repository ||= Repositories::Card.new(ROM.env)
      end

      def payment_repository
        @payment_repository ||= Repositories::Payment.new(ROM.env)
      end
    end
  end
end
