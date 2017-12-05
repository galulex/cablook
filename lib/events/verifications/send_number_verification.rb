module Events
  module Verifications
    class SendNumberVerification < BaseEvent
      def schema
        Dry::Validation.Schema do
          configure { config.messages = :i18n }

          required(:number).value(format?: Constants::Regex::PHONE_NUMBER)
        end
      end

      def run
        check_user!
        send_verification_code
        update_user_verification_token
        token
      end

      private

      def update_user_verification_token
        Repositories::User.new(ROM.env).update(user.id, verification_token: token)
      end

      def send_verification_code
        Twilio::REST::Client.new.api.account.messages.create(
          from: ENV['TWILIO_NUMBER'],
          to: data[:number],
          body: I18n.t('verifications.number.send_verification_token', token: token)
        )
      end

      def user
        @user ||= Repositories::User.new(ROM.env).by_phone_number(data[:number])
      end

      def check_user!
        invalid!([I18n.t('verifications.errors.number.does_not_exist')]) unless user
      end

      def token
        @token ||= rand(1000..9999).to_s
      end
    end
  end
end
