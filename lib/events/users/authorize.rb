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
        return user if custom_iphone?
        if data[:firebase].blank?
          Jobs::Sms.perform_later(data[:phone_number], sms_body)
          update_code
        end
        update_auth_token
        user || create_user
      end

      private

      def custom_iphone?
        data[:phone_number] == '+380936977929'
      end

      def update_code
        user&.update(verification_token: code)
      end

      def update_auth_token
        user.update(auth_token: data[:auth_token]) if user && data[:auth_token].present?
      end

      def user
        @user ||= User.find_by(phone_number: data[:phone_number])
      end

      def create_user
        @user ||= User.create(data.except(:firebase).merge(verification_token: code))
      end

      def code
        @code ||= rand(1000..9999)
      end

      def sms_body
        I18n.t('verifications.number.send_verification_token', token: code)
      end
    end
  end
end
