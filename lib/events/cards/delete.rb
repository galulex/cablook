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
        delete_card if cards.any? { |card| card.id == data[:card_id] }
      end

      private

      def delete_card
        Repositories::Payment.new(ROM.env).nullify_card(data[:card_id])
        card_repository.delete(data[:card_id])
      end

      def cards
        @cards ||= card_repository.by_user(data[:user_id])
      end

      def card_repository
        @card_repository ||= Repositories::Card.new(ROM.env)
      end
    end
  end
end
