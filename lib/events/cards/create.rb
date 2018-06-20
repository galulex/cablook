module Events
  module Cards
    class Create < BaseEvent
      def schema
        Dry::Validation.Schema do
          configure { config.messages = :i18n }

          required(:cardPan).filled(:str?)
          required(:recToken).filled(:str?)
          required(:user_id).filled(:int?)
          optional(:cardType).filled(:str?)
          optional(:currency).filled(:str?)
          optional(:email).filled(:str?)
        end
      end

      def run
        find_user!
        validate!
        update_user_email
        create_card
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

      def card_params
        {
          token: data[:recToken],
          pan: data[:cardPan],
          type: data[:cardType],
          currency: data[:currency],
          user_id: data[:user_id]
        }
      end

      def user
        @user ||= User.find(data[:user_id])
      end
    end
  end
end
