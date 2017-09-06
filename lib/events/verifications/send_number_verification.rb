module Events
  module Verifications
    class SendNumberVerification < BaseEvent
      def schema
        Dry::Validation.Schema do
          required(:number).value(format?: Constants::Regex::PHONE_NUMBER)
        end
      end

      def run
        send_verification_code
        token
      end

      private

      def send_verification_code
        Twilio::REST::Client.new.api.account.messages.create(
          from: Rails.application.secrets.twilio_number,
          to: data[:number],
          body: I18n.t('verifications.number.send_token_message', code: token)
        )
      end

      def token
        @token ||= rand(1000..9999).to_s
      end
    end
  end
end
