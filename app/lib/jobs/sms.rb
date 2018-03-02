module Jobs
  class Sms < ActiveJob::Base
    def perform(number, body)
      Twilio::REST::Client.new.api.account.messages.create(
        from: 'cablook',
        to: number,
        body: body
      )
    end
  end
end
