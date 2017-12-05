module Events
  module Verifications
    class VerifyEmail < BaseEvent
      def schema
        Dry::Validation.Schema do
          configure { config.messages = :i18n }

          required(:email).value(format?: Constants::Regex::EMAIL)
          required(:token).filled(:str?)
        end
      end

      def run
        check_user!
        verify!
      end

      private

      def user
        @user ||= users_repository.by_email(data[:email])
      end

      def check_user!
        invalid!([I18n.t('verifications.errors.email.does_not_exist')]) unless user
      end

      def verify!
        if user.confirmation_token == data[:token]
          set_confirmation_to_nil
        else
          invalid!(errors: [I18n.t('verifications.errors.invalid_or_expired')])
        end
      end

      def set_confirmation_to_nil
        users_repository.update(user.id, confirmation_token: nil)
      end

      def users_repository
        @users_repository ||= Repositories::User.new(ROM.env)
      end
    end
  end
end
