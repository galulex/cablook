module Api
  module Verifications
    class PhoneNumbersController < ApiApplicationController
      def send_verification
        Events::Verifications::SendNumberVerification.call(phone_number: phone_number)
        render json: { messages: ['Message has been sent'] }
      end

      private

      def phone_number
        params.require(:phone_number)
      end
    end
  end
end
