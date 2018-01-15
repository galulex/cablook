module Api
  module Verifications
    class EmailsController < ApiApplicationController
      def send_verification
        Events::Verifications::SendEmailVerification.call(email: email)
        render json: { messages: ['Message has been sent'] }
      end

      def verify
        Events::Verifications::VerifyEmail.call(email: email,
                                                token: confirmation_token)
        render json: { messages: ['verified'] }
      end

      private

      def email
        params.require(:email)
      end

      def confirmation_token
        params.require(:token)
      end
    end
  end
end
