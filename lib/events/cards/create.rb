module Events
  module Cards
    class Create < BaseEvent
      def schema
        Dry::Validation.Schema do
          configure { config.messages = :i18n }

          required(:user_id).filled(:int?)
          optional(:masked_card).filled(:str?)
          optional(:card_type).filled(:str?)
          optional(:currency).filled(:str?)
        end
      end

      def run
        find_user!
        validate!
        create_card
        telegram_message
        #UserMailer.new_card(data[:email], data[:cardPan]).deliver_later
        @card
        payment_page_link
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

      def card_params
        {
          token: fondy.order_id,
          pan: '****',
          type: 'verify',
          user_id: data[:user_id]
        }
      end

      def user
        @user ||= User.find(data[:user_id])
      end

      def telegram_message
        return if user.telegram.blank?
        TelegramOrder.new(user.telegram).confirm_card
      end

      def fondy
        @fondy ||= Fondy::Verify.new(user)
      end

      def payment_page_link
        fondy.call[:checkout_url]
      end
    end
  end
end
