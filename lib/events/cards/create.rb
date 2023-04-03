module Events
  module Cards
    class Create < BaseEvent
      def schema
        Dry::Validation.Schema do
          configure { config.messages = :i18n }

          required(:user_id).filled(:int?)
          required(:masked_card).filled(:str?)
          required(:card_type).filled(:str?)
          required(:currency).filled(:str?)
          required(:rectoken).filled(:str?)
          required(:sender_email).filled(:str?)
        end
      end

      def run
        find_user!
        validate!
        create_card
        update_user_email
        telegram_message
        #UserMailer.new_card(data[:email], data[:cardPan]).deliver_later
        @card
      end

      private

      def find_user!
        invalid!([I18n.t('cards.user_not_found')]) unless user
      end

      def validate!
        @card = Card.new(card_params)
        invalid!(@card.errors.values.flatten) if @card.invalid?
      end

      def create_card
        @card.save
      end

      def update_user_email
        user.update!(email: data[:sender_email])
      end

      def card_params
        {
          token: data[:rectoken],
          pan: "#{data[:masked_card].first(2)}****#{data[:masked_card].last(4)}",
          type: data[:card_type],
          currency: data[:currency],
          user_id: data[:user_id],
          payment_system: Card::PAYMENT_SYSTEM
        }
      end

      def user
        @user ||= User.find(data[:user_id])
      end

      def telegram_message
        return if user.telegram.blank?
        TelegramOrder.new(user.telegram).confirm_card
      end
    end
  end
end
