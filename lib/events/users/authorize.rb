module Events
  module Users
    class Authorize < BaseEvent
      def schema
        Dry::Schema.Params do
          # # configure { config.messages = :i18n }

          optional(:phone_number).value(format?: Constants::Regex::PHONE_NUMBER)
          optional(:email).filled(:str?)
        end
      end

      def run
        update_user
        user || create_user
      end

      private

      def update_user
        user.update(auth_token: data[:auth_token], locale: data[:locale]) if user && data[:auth_token].present?
      end

      def user
        @user ||= user_by_phone_number || user_by_email
      end

      def user_by_phone_number
        return unless data[:phone_number].present?

        @user_by_phone_number ||= User.find_by(phone_number: data[:phone_number])
      end

      def user_by_email
        return unless data[:email].present?

        @user_by_email ||= User.find_by(email: data[:email])
      end

      def create_user
        @create_user ||= User.create(data)
      end
    end
  end
end
