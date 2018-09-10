module Events
  module Cards
    class Update < BaseEvent
      def schema
        Dry::Validation.Schema do
          configure { config.messages = :i18n }

          required(:orderReference).filled(:str?)
          required(:recToken).filled(:str?)
        end
      end

      def run
        return if card.nil?
        update_card
        @card
      end

      private

      def card
        @card ||= Card.find_by(token: data[:orderReference])
      end

      def update_card
        @card.update(token: data[:recToken])
      end
    end
  end
end
