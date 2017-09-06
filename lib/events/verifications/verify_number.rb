module Events
  module Verifications
    class VerifyNumber < BaseEvent
      def schema
        Dry::Validation.Schema do
          required(:user_id).filled(:int?)
          required(:token).filled(:str?)
        end
      end

      def run
        if verification.token == data[:token] && !verification.expired
          { messages: ['verified'] }
        else
          invalid!(errors: [I18n.t('verifications.errors.invalid_or_expired')])
        end
      end

      private

      def verification
        Repositories::User.new.by_user_id_and_type(
          data[:user_id],
          Constants::Verifications::NUMBER
        )
      end
    end
  end
end
