module Events
  module Cards
    class New < BaseEvent
      def schema
        Dry::Validation.Schema do
          configure { config.messages = :i18n }

          required(:user_id).filled(:int?)
        end
      end

      def run
        find_user!
        create_card_verification_link
      end

      private

      def find_user!
        invalid!([I18n.t('cards.user_not_found')]) unless user
      end

      def user
        @user ||= User.find(data[:user_id])
      end

      def create_card_verification_link
        Fondy::Verify.new(user).call
      end
    end
  end
end
