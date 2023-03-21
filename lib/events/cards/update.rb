module Events
  module Cards
    class Update < BaseEvent
      def schema
        Dry::Validation.Schema do
          configure { config.messages = :i18n }

          required(:rectoken).filled(:str?)
          required(:order_id).filled(:str?)
          optional(:masked_card).filled(:str?)
          optional(:sender_email).filled(:str?)
          optional(:card_type).filled(:str?)
          optional(:currency).filled(:str?)
        end
      end

      def run
        return destroy_duplicate_cart if duplicate_card
        update_card unless card.nil?
        update_user_email unless user.nil?
      end

      private

      def card
        @card ||= Card.find_by(token: data[:order_id])
      end

      def update_card
        card.update(params)
      end

      def update_user_email
        user.update!(email: data[:sender_email])
      end

      def user
        @user ||= User.find(card.user_id)
      end

      def params 
        {
          token: data[:rectoken],
          pan: "#{data[:masked_card].first(2)}****#{data[:masked_card].last(4)}",
          type: data[:card_type],
          currency: data[:currency]
        }
      end

      def duplicate_card
        @duplicate_card ||= Card.find_by(token: data[:rectoken])
      end

      def destroy_duplicate_cart
        card.destroy!
      end
    end
  end
end
