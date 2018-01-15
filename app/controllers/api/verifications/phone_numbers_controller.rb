module Api
  module Verifications
    class PhoneNumbersController < ApplicationController
      def send_verification
        Events::Verifications::SendNumberVerification.call(number: phone_number)
        render json: { messages: ['Message has been sent'] }
      end

      def verify
        Events::Verifications::VerifyNumber.call(number: phone_number,
                                                 token: verification_token)
        render json: { messages: ['verified'] }
      end

      private

      def phone_number
        params.require(:phone_number)
      end

      def verification_token
        params.require(:token)
      end
    end
  end
end
