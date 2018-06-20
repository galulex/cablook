module Events
  module Verifications
    class SendNumberVerification < BaseEvent
      def schema
        Dry::Validation.Schema do
          configure { config.messages = :i18n }

          required(:phone_number).value(format?: Constants::Regex::PHONE_NUMBER)
        end
      end

      def run
        check_user!
        send_verification_code
        update_user_verification_token
        token
      end

      private

      def check_user!
        invalid!([I18n.t('verifications.errors.number.does_not_exist')]) unless user
      end

      def send_verification_code
        Jobs::Sms.perform_later(data[:phone_number], sms_body)
      end

      def sms_body
        I18n.t('verifications.number.send_verification_token', token: token)
      end

      def token
        @token ||= rand(1000..9999).to_s
      end

      def user
        @user ||= User.find_by(phone_number: data[:phone_number])
      end

      def update_user_verification_token
        user.update(verification_token: token)
      end
    end
  end
end
