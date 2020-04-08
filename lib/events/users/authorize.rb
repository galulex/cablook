module Events
  module Users
    class Authorize < BaseEvent
      def schema
        Dry::Validation.Schema do
          configure { config.messages = :i18n }

          required(:phone_number).value(format?: Constants::Regex::PHONE_NUMBER)
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
        @user ||= User.find_by(phone_number: data[:phone_number])
      end

      def create_user
        @user ||= User.create(data)
      end
    end
  end
end
