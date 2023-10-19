module Events
  module Users
    class Authorize < BaseEvent
      def schema
        Dry::Schema.Params do
          optional(:phone_number).value(format?: Constants::Regex::PHONE_NUMBER)
          optional(:email).filled(:str?)
        end
      end

      def run
        validate_params
        update_user
        user || create_user
        update_user_verification_code
        send_code_to_email
        user
      end

      private

      def validate_params
        invalid!('One of email or phone number required') if data[:phone_number].blank? && data[:email].blank?
      end

      def update_user
        user.update(auth_token: data[:auth_token], locale: data[:locale]) if user && data[:auth_token].present?
      end

      def update_user_verification_code
        return unless data[:email].present?

        user.regenerate_auth_token
        user.update(verification_code: verification_code)
      end

      def send_code_to_email
        return unless data[:email].present?

        UserMailer.verification_code_email(data[:email], verification_code).deliver_later
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

      def verification_code
        @verification_code ||= rand(100_000..999_999).to_s
      end

      def create_user
        @create_user ||= User.create(data)
      end
    end
  end
end
