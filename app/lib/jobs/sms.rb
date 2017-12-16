module Jobs
  class Sms < ActiveJob::Base
    def perform(number, code)
      Twilio::REST::Client.new.api.account.messages.create(
        from: ENV['TWILIO_NUMBER'],
        to: number,
        body: I18n.t('verifications.number.send_verification_token', token: code)
      )
    end
  end
end
