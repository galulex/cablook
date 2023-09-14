module Events
  module Cards
    class Create < BaseEvent
      def schema
        Dry::Schema.Params do
          # configure { config.messages = :i18n }

          required(:cardPan).filled(:str?)
          required(:user_id).filled(:int?)
          required(:recToken).maybe(:str?)
          optional(:cardType).filled(:str?)
          optional(:currency).filled(:str?)
          optional(:email).filled(:str?)
        end
      end

      def run
        find_user!
        validate!
        update_user_email
        return if data[:transactionStatus] == 'Declined'
        create_card
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
        user.update(email: data[:email])
      end

      def rec_token
        data[:recToken].presence || data[:orderReference]
      end

      def card_params
        {
          token: rec_token,
          pan: data[:cardPan],
          type: data[:cardType],
          currency: data[:currency],
          user_id: data[:user_id],
          payment_system: settings.payment_system
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
