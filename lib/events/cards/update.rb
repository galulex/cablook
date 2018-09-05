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
        card
        update_card
        @card
      end

      private

      def card
        @card ||= Card.where(token: data[:orderReference])
      end

      def update_card
        return if data[:recToken].empty?
        @card.update(token: data[:recToken])
      end
    end
  end
end
