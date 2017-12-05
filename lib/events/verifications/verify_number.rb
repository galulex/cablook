module Events
  module Verifications
    class VerifyNumber < BaseEvent
      def schema
        Dry::Validation.Schema do
          configure { config.messages = :i18n }

          required(:number).value(format?: Constants::Regex::PHONE_NUMBER)
          required(:token).filled(:str?)
        end
      end

      def run
        check_user!
        if user.verification_token == data[:token]
          set_verification_to_nil
        else
          invalid!(errors: [I18n.t('verifications.errors.invalid_or_expired')])
        end
      end

      private

      def set_verification_to_nil
        users_repository.update(user.id, verification_token: nil)
      end

      def user
        @user ||= users_repository.by_phone_number(data[:number])
      end

      def check_user!
        invalid!([I18n.t('verifications.errors.number.does_not_exist')]) unless user
      end

      def users_repository
        @users_repository ||= Repositories::User.new(ROM.env)
      end
    end
  end
end
